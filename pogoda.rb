
require_relative 'meteoservice.rb'

current_path = File.dirname(__FILE__)
file_name = current_path + '/city_list.xml'


puts 'Введите название города:'
city_name = STDIN.gets.chomp

file = File.new(file_name, 'r:utf-8')
city_id = Meteoservice.get_city_id(file, city_name)
file.close


meteoservice = Meteoservice.new
meteoservice.take_data(city_id)
meteoservice.show_weather





