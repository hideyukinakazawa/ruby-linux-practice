# Raspberry Pi のシステム状態を確認する監視スクリプト
# CPU温度・ディスク・メモリ・Swapを取得し、状態判定後にレポートへ保存

puts "=== Raspberry Pi System Check ==="

# --- Basic system information ---

# ホスト名・実行ユーザー・稼働時間をLinuxコマンドから取得
puts "\n--- Hostname ---"
system("hostname")

puts "\n--- User ---" 
system("whoami")

puts "\n--- Uptime ---"
system("uptime")

puts "\n--- CPU Temperature ---"

# SSHサービスの稼働状況を確認する
def get_ssh_status
  service_status = `systemctl is-active ssh`.strip

  if service_status == "active"
    "NORMAL"
  else
    "WARNING"
  end
end

# ---Monitoring methods ---

# CPU使用率が高いプロセス上位5件を取得する
def get_top_processes
  process_info =
    `ps -eo pid,stat,comm,%cpu,%mem --sort=-%cpu | head -n 6`

  lines = process_info.lines.drop(1)

  lines.map do |line|
    pid, stat, command, cpu, memory = line.split

    {
      pid: pid.to_i,
      stat: stat,
      command: command,
      cpu: cpu.to_f,
      memory: memory.to_f
    }
  end
end


# Load Averageを取得してHashで返す
def get_load_average
  load_info = File.read("/proc/loadavg").split
 
  {
    one_minute: load_info[0].to_f,
    five_minutes: load_info[1].to_f,
    fifteen_minutes: load_info[2].to_f
  }
end

# メモリとSwapの情報を取得し、それぞれの使用率を計算する

def get_memory_swap_usage
  memory_info = `free -m`

  memory_line = memory_info.lines.find { |line| line.start_with?("Mem:") }
  swap_line = memory_info.lines.find { |line| line.start_with?("Swap:") }

  memory_values = memory_line.split
  swap_values = swap_line.split

  total_memory= memory_values[1].to_f
  available_memory = memory_values[6].to_f

  total_swap = swap_values[1].to_f
  used_swap = swap_values[2].to_f

  memory_usage = ((total_memory - available_memory) / total_memory * 100).round(1)
  swap_usage = total_swap.zero? ? 0.0 : (used_swap / total_swap * 100).round(1)

  {
  raw: memory_info,
  memory_usage: memory_usage,
  swap_usage: swap_usage
  }

end

def write_report(cpu_temperature, 
                 disk_usage, 
                 memory_usage,
                 swap_usage, 
                 load_average,
                 system_status,
                 overall_status,
                 system_message,
                 top_processes)

    File.open("system_report.txt", "w") do |file|
    file.puts "--- System Summary ---"
    
    file.puts "CPU temperature: #{cpu_temperature} C"
    file.puts "Disk usage: #{disk_usage}%"
    file.puts "Memory usage: #{memory_usage}%"
    file.puts "Swap usage: #{swap_usage}%"

    file.puts "Load Average:"
    file.puts format("1 min : %.2f", load_average[:one_minute])
    file.puts format("5 min : %.2f", load_average[:five_minutes])
    file.puts format("15 min: %.2f", load_average[:fifteen_minutes])

    file.puts "\n--- Top Processes ---"
    
    top_processes.each do |process|
      file.puts "PID #{process[:pid]} | #{process[:command]} | " \
                "CPU #{process[:cpu]}% | MEM #{process[:memory]}% | " \
                "STAT #{process[:stat]}"
    end

    system_status.each do |name, status|
      display_name =
        if [:cpu, :ssh].include?(name)
          name.to_s.upcase
        else
          name.to_s.capitalize
        end
      file.puts "#{display_name} status: #{status}"
    end    

    file.puts "Overall status: #{overall_status}"
    file.puts "System message: #{system_message}"
  end
end

# 各監視項目の状態からシステム全体の状態を判定する
def overall_status_from(statuses)
    if statuses.include?("WARNING")
      "WARNING"
    elsif statuses.include?("WARM")
      "WARM"
    else
      "NORMAL"
    end
end

# dfの出力から「xx％」の数値部分だけを抽出してIntegerへ格納
def get_disk_usage
    disk_info = `df -h /`
    disk_info.match(/(\d+)%/)[1].to_i
end

# 使用率と2つの閾値から NORMAL / WARM / WARNING を判定
def status_from_value(usage, warm_threshold, warning_threshold)
    if usage >= warning_threshold
        "WARNING"
    elsif usage >= warm_threshold
        "WARM"
    else
        "NORMAL"
    end
end

# vcgencmdからCPU温度を取得してFloatとして返す
def get_cpu_temperature
    cpu_info = `vcgencmd measure_temp`
    cpu_info.match(/[\d.]+/)[0].to_f
end

load_average = get_load_average

puts "\n--- Load Average ---"
puts format("1 min : %.2f", load_average[:one_minute])
puts format("5 min : %.2f", load_average[:five_minutes])
puts format("15 min: %.2f", load_average[:fifteen_minutes])

# --- CPU Monitoring ---

cpu_temperature = get_cpu_temperature

# CPU温度に応じて状態を判定
cpu_status = status_from_value(cpu_temperature, 50, 70)

# --- Process monitoring ---
top_processes = get_top_processes

puts "\n--- Top Processes ---"

top_processes.each do |process|
  puts "PID #{process[:pid]} | #{process[:command]} |" \
       "CPU #{process[:cpu]}% | MEM #{process[:memory]}% | " \
       "STAT #{process[:stat]}"
end 

# --- Disk monitoring ---

disk_usage = get_disk_usage

puts "Disk usage: #{disk_usage}%"

disk_status = status_from_value(disk_usage, 70, 90)

puts "Disk status: #{disk_status}"

# --- Memory and Swap monitoring ---

puts "\n--- Memory Usage ---"

# free -mでメモリとSwapの使用状況をMB単位で取得

memory_swap = get_memory_swap_usage

puts memory_swap[:raw]

memory_usage = memory_swap[:memory_usage]
swap_usage = memory_swap[:swap_usage]

swap_status = status_from_value(swap_usage, 70, 90)
memory_status = status_from_value(memory_usage, 70, 90)

puts "Swap usage: #{swap_usage}%" 
puts "Swap status: #{swap_status}"  

puts "Memory usage: #{memory_usage}%"
puts "Memory status: #{memory_status}"

# CPU・Disk・Memory・Swap・SSHのうち最も深刻な状態をシステム全体の状態とする

ssh_status = get_ssh_status

system_status = {
  cpu: cpu_status,
  disk: disk_status,
  memory: memory_status,
  swap: swap_status,
  ssh: ssh_status,
}

puts system_status

# CPU・Disk・Memory・Swapのうち最も深刻な状態をシステム全体の状態とする
statuses = system_status.values

overall_status = overall_status_from(statuses)

# システム全体の状態に応じて、人が理解しやすいメッセージを返す
def message_from_status(status)
    case status
    when "WARNING"
      "ALERT: System Status is WARNING. Please check CPU, Disk, Memory, and Swap."
    when "WARM"
      "NOTICE: System Status is WARM. Please monitor the system."
    else
        "OK: System Status is NORMAL."
    end
end

system_message = message_from_status(overall_status)

puts "System message: #{system_message}"

write_report(
  cpu_temperature,
  disk_usage, 
  memory_usage, 
  swap_usage, 
  load_average,
  system_status,
  overall_status, 
  system_message,
  top_processes
)

puts "--- System Summary ---"

system_status.each do |name, status|
  display_name = 
    if [:cpu, :ssh].include?(name)
      name.to_s.upcase
    else
      name.to_s.capitalize
    end

  puts "#{display_name}_status: #{status}"
  end

  puts "Overall_status: #{overall_status}"




