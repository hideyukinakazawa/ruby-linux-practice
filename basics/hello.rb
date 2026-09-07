puts "== Raspberry Pi Information =="

puts "User: #{ENV['USER']}"
puts "Home: #{ENV['HOME']}"
puts "Current Directory: #{Dir.pwd}"

puts "\nFiles:"
Dir.entries(".").each do |file|
    puts file 
end
