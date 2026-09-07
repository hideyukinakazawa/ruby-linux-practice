name = "raspi4"
temperature = 39.4

puts "Machine: #{name}"
puts "CPU Temperature: #{temperature} C"

if temperature >= 70
    puts "WARNING"
else 
    puts "Normal"
end
p