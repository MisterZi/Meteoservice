
require_relative 'meteoservice.rb'

puts 'Введите название города:'
city_name = STDIN.gets.chomp

meteoservice = Meteoservice.new(city_name)
meteoservice.show_weather