raw = `vcgencmd measure_temp`

temperature = raw.match(/[\d.]+/)[0].to_f

if temperature >= 70
    statsus =  "WARNING"
elsif temperature >= 50
    status = "WARM"
else
    status = "NORMAL"
end

puts "CPU Temperature: #{temperature} C"
puts "Status: #{status}"

time = Time.now

File.open("cpu_log.txt", "a") do |file|
    file.puts "#{time} | #{temperature} C | #{status}"

end
