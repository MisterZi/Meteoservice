require 'net/http'
require 'uri'
require 'rexml/document'
require 'date'

# http://export.yandex.ru/weather-ng/forecasts/26063.xml

uri = URI.parse('http://xml.meteoservice.ru/export/gismeteo/point/69.xml')

response = Net::HTTP.get_response(uri)
# исключения!!

doc = REXML::Document.new(response.body)

city_name = doc.root.elements['REPORT/TOWN'].attributes['index']
date_str = doc.root.elements['REPORT/TOWN/FORECAST'].attributes['day'] + '.' +
    doc.root.elements['REPORT/TOWN/FORECAST'].attributes['month'] + '.' +
    doc.root.elements['REPORT/TOWN/FORECAST'].attributes['year']
date = Date.parse(date_str)
time = doc.root.elements['REPORT/TOWN/FORECAST'].attributes['hour']
temperature = doc.root.elements['REPORT/TOWN/FORECAST/TEMPERATURE'].attributes['max']
wind = doc.root.elements['REPORT/TOWN/FORECAST/WIND'].attributes['max']
phenomena = doc.root.elements['REPORT/TOWN/FORECAST/PHENOMENA'].attributes['cloudiness'].to_i
cloudiness = ''

case phenomena
  when 0 then cloudiness = 'ясно'
  when 1 then cloudiness = 'малооблачно'
  when 2 then cloudiness = 'облачно'
  when 3 then cloudiness = 'пасмурно'
end


 puts "Погода в городе #{city_name} на #{time} час #{date.strftime('%d-%m-%Y')}:"
puts "#{temperature} градусов, #{cloudiness}, ветер #{wind} м/с"
