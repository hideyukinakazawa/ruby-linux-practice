lines = File.readlines("cpu_log.txt")

temperatures = lines.map do |line|
    line.match(/(\d+\.\d+) C/)[1].to_f
end

puts "Measurement count: #{temperatures.size}"
puts "Highest temperature: #{temperatures.max} C"
puts "Average temperature: #{(temperatures.sum / temperatures.size).round(1)} C"
