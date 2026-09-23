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

# ---Monitoring methods ---

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
def status_from_usage(usage, warm_threshold, warning_threshold)
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

# --- CPU Monitoring ---

cpu_temperature = get_cpu_temperature

# CPU温度に応じて状態を判定
if cpu_temperature >= 70
    cpu_status = "WARNING"
elsif cpu_temperature >= 50
    cpu_status = "WARM"
else
    cpu_status = "NORMAL"
end

# --- Disk monitoring ---

disk_usage = get_disk_usage

puts "Disk usage: #{disk_usage}%"

disk_status = status_from_usage(disk_usage, 70, 90)

puts "Disk status: #{disk_status}"

# --- Memory and Swap monitoring ---

puts "\n--- Memory Usage ---"

# free -mでメモリとSwapの使用状況をMB単位で取得
memory_info = `free -m`
puts memory_info

# freeの出力からメモリ情報を抽出
memory_line = memory_info.lines.find { |line| line.start_with?("Mem:") }
memory_values = memory_line.split

# freeの出力からSwap情報を抽出
swap_line = memory_info.lines.find { |line| line.start_with?("Swap:")}
swap_values = swap_line.split

# Swap使用率を計算
total_swap = swap_values[1].to_f
used_swap = swap_values[2].to_f
swap_usage = total_swap.zero? ? 0.0 : (used_swap / total_swap * 100).round(1)

swap_status = status_from_usage(swap_usage, 70, 90)

puts "Swap usage: #{swap_usage}%"
puts "Swap status: #{swap_status}"
    
# availableを基準に実際に利用可能なメモリを考慮して使用率を計算
total_memory = memory_values[1].to_f
available_memory = memory_values[6].to_f
memory_usage = ((total_memory - available_memory) / total_memory * 100).round(1)

memory_status = status_from_usage(memory_usage, 70, 90)


puts "Memory usage: #{memory_usage}%"
puts "Memory status: #{memory_status}"

# --- Overall status ---

# CPU・Disk・Memory・Swapのうち最も深刻な状態をシステム全体の状態とする
statuses = [cpu_status, disk_status, memory_status, swap_status]

overall_status = overall_status_from(statuses)

puts "--- System Summary ---"
puts "CPU_status: #{cpu_status}"
puts "Disk_status: #{disk_status}"
puts "Memory_status: #{memory_status}"
puts "Swap_status: #{swap_status}"
puts "Overall_status: #{overall_status}"

# --- Report output ---

# 最新の監視結果をsystem_report.txtへ保存
# "W"モード → 実行の度に前回の内容を上書き
File.open("system_report.txt", "w") do |file|
  file.puts "--- System Summary ---"

  file.puts "CPU temperature: #{cpu_temperature} C"
  file.puts "CPU status: #{cpu_status}"

  file.puts "Disk usage: #{disk_usage}%"
  file.puts "Disk status: #{disk_status}"

  file.puts "Memory usage: #{memory_usage}%"
  file.puts "Memory status: #{memory_status}"

  file.puts "Swap usage: #{swap_usage}%"
  file.puts "Swap status: #{swap_status}"
  
  file.puts "Overall status: #{overall_status}"
end






