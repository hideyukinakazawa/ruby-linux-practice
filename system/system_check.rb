puts "=== Raspberry Pi System Check ==="

puts "\n--- Hostname ---"
system("hostname")

puts "\n--- User ---" 
system("whoami")

puts "\n--- Uptime ---"
system("uptime")

puts "\n--- CPU Temperature ---"

def get_disk_usage
    disk_info = `df -h /`
    disk_info.match(/(\d+)%/)[1].to_i
end

def status_from_usage(usage, warm_threshold, warning_threshold)
    if usage >= warning_threshold
        "WARNING"
    elsif usage >= warm_threshold
        "WARM"
    else
        "NORMAL"
    end
end

def get_cpu_temperature
    cpu_info = `vcgencmd measure_temp`
    cpu_info.match(/[\d.]+/)[0].to_f
end

cpu_temperature = get_cpu_temperature

if cpu_temperature >= 70
    cpu_status = "WARNING"
elsif cpu_temperature >= 50
    cpu_status = "WARM"
else
    cpu_status = "NORMAL"
end

disk_usage = get_disk_usage

puts "Disk usage: #{disk_usage}%"

disk_status = status_from_usage(disk_usage, 70, 90)

puts "Disk status: #{disk_status}"

puts "\n--- Memory Usage ---"

memory_info = `free -m`
puts memory_info

memory_line = memory_info.lines.find { |line| line.start_with?("Mem:") }
memory_values = memory_line.split

swap_line = memory_info.lines.find { |line| line.start_with?("Swap:")}
swap_values = swap_line.split
total_swap = swap_values[1].to_f
used_swap = swap_values[2].to_f
swap_usage = total_swap.zero? ? 0.0 : (used_swap / total_swap * 100).round(1)

swap_status = status_from_usage(swap_usage, 70, 90)

puts "Swap usage: #{swap_usage}%"
puts "Swap status: #{swap_status}"
    

total_memory = memory_values[1].to_f
available_memory = memory_values[6].to_f

memory_usage = ((total_memory - available_memory) / total_memory * 100).round(1)

memory_status = status_from_usage(memory_usage, 70, 90)


puts "Memory usage: #{memory_usage}%"
puts "Memory status: #{memory_status}"

if cpu_status == "WARNING" || disk_status == "WARNING" || memory_status == "WARNING"
  overall_status = "WARNING"
elsif cpu_status == "WARM" || disk_status == "WARM" || memory_status == "WARM"
  overall_status = "WARM"
else
  overall_status = "NORMAL"
end

puts "--- System Summary ---"
puts "CPU_status: #{cpu_status}"
puts "Disk_status: #{disk_status}"
puts "Memory_status: #{memory_status}"
puts "Overall_status: #{overall_status}"

File.open("system_report.txt", "w") do |file|
  file.puts "--- System Summary ---"

  file.puts "CPU temperature: #{cpu_temperature} C"
  file.puts "CPU status: #{cpu_status}"

  file.puts "Disk usage: #{disk_usage}%"
  file.puts "Disk status: #{disk_status}"

  file.puts "Memory usage: #{memory_usage}%"
  file.puts "Memory status: #{memory_status}"
  
  file.puts "Overall status: #{overall_status}"
end






