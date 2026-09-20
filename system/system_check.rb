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

swap_line = memory_info.lines.find { |line| line.start_with?("Swap:")}
swap_values = swap_line.split
total_swap = swap_values[1].to_f
used_swap = swap_values[2].to_f
swap_usage = total_swap.zero? ? 0.0 : (used_swap / total_swap * 100).round(1)

if swap_usage >= 80
    swap_status = "WARNING"
elsif swap_usage >= 50
    swap_status = "WARM"
else 
    swap_status = "NORMAL"
end

puts "Swap usage: #{swap_usage}%"
puts "Swap status: #{swap_status}"
    

total_memory = memory_values[1].to_f
available_memory = memory_values[6].to_f

memory_usage = ((total_memory - available_memory) / total_memory * 100).round(1)

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






