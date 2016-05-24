
require 'net/http'
require 'uri'
require 'rexml/document'
require 'date'

class Meteoservice

  def self.get_city_id(xml_file, city_name)
    doc = REXML::Document.new(xml_file)

    city_id = 69

    doc.root.elements.each do |city|
      city_id = city.attributes['value'] if city_name == city.text
    end
    return city_id
  end


  def take_data(city_id)
    @uri = URI.parse("http://xml.meteoservice.ru/export/gismeteo/point/#{city_id}.xml")
    response = Net::HTTP.get_response(@uri)
    # исключения!!
    doc = REXML::Document.new(response.body)


    @meteodata = {city_name: "#{URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])}"}

    data = []

    doc.root.elements.each('REPORT/TOWN/FORECAST') do |forecast|
      another_data = {date: Date.parse(
              forecast.attributes['day'] + '.' +
              forecast.attributes['month'] + '.' +
              forecast.attributes['year'])}
      another_data[:time] = forecast.attributes['hour']
      another_data[:temperature] = forecast.elements['TEMPERATURE'].attributes['max']
      another_data[:wind] = forecast.elements['WIND'].attributes['max']

      case forecast.elements['PHENOMENA'].attributes['cloudiness'].to_i
        when 0 then
          another_data[:cloudiness] = 'ясно'
        when 1 then
          another_data[:cloudiness] = 'малооблачно'
        when 2 then
          another_data[:cloudiness] = 'облачно'
        when 3 then
          another_data[:cloudiness] = 'пасмурно'
      end

      data << another_data
    end
    @meteodata[:data] = data
  end

  def show_weather
    puts "\nПогода в городе #{@meteodata[:city_name]}: "

    @meteodata[:data].each do |data|
      puts "\n- на #{data[:time]}-й час #{data[:date].strftime('%d-%m-%Y')}:"
      puts "#{data[:temperature]} градусов, #{data[:cloudiness]}, ветер #{data[:wind]} м/с"
    end
  end

end