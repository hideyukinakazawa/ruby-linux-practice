puts "=== Raspberry Pi System Check ==="

puts "\n--- Hostname ---"
system("hostname")

puts "\n--- User ---" 
system("whoami")

puts "\n--- Uptime ---"
system("uptime")

puts "\n--- CPU Temperature ---"
system("vcgencmd measure_temp")



