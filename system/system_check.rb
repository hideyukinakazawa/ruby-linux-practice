puts "=== Raspberry Pi System Check ==="

puts "\n--- Hostname ---"
system("hostname")

puts "\n--- User ---" 
system("whoami")

puts "\n--- Uptime ---"
system("uptime")

puts "\n--- CPU Temperature ---"

cpu_info = `vcgencmd measure_temp`
puts cpu_info

cpu_temperature = cpu_info.match(/[\d.]+/)[0].to_f

if cpu_temperature >= 70
    cpu_status = "WARNING"
elsif cpu_temperature >= 50
    cpu_status = "WARM"
else
    cpu_status = "NORMAL"
end

disk_info = `df -h /`

puts disk_info

disk_usage = disk_info.match(/(\d+)%/)[1].to_i

puts "Disk usage: #{disk_usage}%"

if disk_usage > 90
    disk_status = "WARNING"
elsif disk_usage >= 70
    disk_status = "WARM"
else
    disk_status = "NORMAL"
end

puts "Disk status: #{disk_status}"

puts "\n--- Memory Usage ---"

memory_info = `free -m`
puts memory_info

memory_line = memory_info.lines.find { |line| line.start_with?("Mem:") }
memory_values = memory_line.split
total_memory = memory_values[1].to_f
used_memory = memory_values[2].to_f
memory_usage = (used_memory / total_memory * 100).round(1)

if memory_usage >= 90
    memory_status = "WARNING"
elsif memory_usage >= 70
    memory_status = "WARM"
else
    memory_status = "NORMAL"
end

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




