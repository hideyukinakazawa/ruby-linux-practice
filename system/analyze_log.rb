lines = File.readlines("cpu_log.txt")

temperatures = lines.map do |line|
    line.match(/(\d+\.\d+) C/)[1].to_f
end

def highest_temperature(temperatures)
    temperatures.max
end

def average_temperature(temperatures)
    temperatures.sum / temperatures.size
end

def lowest_temperature(temperatures)
    temperatures.min
end

def temperature_range(temperatures)
    temperatures.max - temperatures.min
end

puts "Measurement count: #{temperatures.size}"

highest = highest_temperature(temperatures)
puts "Highest temperature: #{highest} C"

average = average_temperature(temperatures)
puts "Average temperature: #{average.round(1)} C"

lowest = lowest_temperature(temperatures)
puts "Lowest temperature: #{lowest} C"

range = temperature_range(temperatures)
puts "Temperature range: #{range} C"

count = temperatures.size

def write_report(count, highest, average, lowest, range)
  File.open("cpu_report.txt", "w") do |file|
  file.puts "CPU Temperature Report"
  file.puts "Measurement count: #{count}"
  file.puts "Highest temperature:  #{highest} C"
  file.puts "Average temperature: #{average.round(1)} C"
  file.puts "Lowest temperature: #{lowest} C"
  file.puts "Temperature range: #{range.round(1)} C"
  end
end

write_report(count, highest, average, lowest, range)

