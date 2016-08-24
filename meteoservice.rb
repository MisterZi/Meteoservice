
require 'net/http'
require 'uri'
require 'rexml/document'
require 'date'

class Meteoservice

  def initialize(city_name)
    @city_name = city_name
  end

  # Получает id введенного города из списка city_list.xml
  def get_city_id
    current_path = File.dirname(__FILE__)
    file_name = current_path + '/city_list.xml'
    file = File.new(file_name, 'r:utf-8')
    doc = REXML::Document.new(file)
    file.close

    city_id = nil
    doc.root.elements.each do |city|
      city_id = city.attributes['value'] if @city_name == city.text
    end

    # Если такого города нет - завершаем программу
    if city_id.nil?
      abort('Город не найден!')
    else
      @meteodata = {city_id: "#{city_id}"}
    end
  end

  # Делает запрос на метеосервис (meteoservice.ru) и получает с него xml с данными о погоде
  def take_data
    uri = URI.parse("http://xml.meteoservice.ru/export/gismeteo/point/#{@meteodata[:city_id]}.xml")
    # Исключения на различные ошибки Net::HTTP
    begin
      response = Net::HTTP.get_response(uri)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
      abort "Ошибка! #{error}"
    end

    doc = REXML::Document.new(response.body)

    @meteodata[:city_name] = URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

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
    get_city_id
    take_data

    puts "\nПогода в городе #{@meteodata[:city_name]}: "

    @meteodata[:data].each do |data|
      puts "\n- на #{data[:time]}-й час #{data[:date].strftime('%d-%m-%Y')}:"
      puts "#{data[:temperature]} градусов, #{data[:cloudiness]}, ветер #{data[:wind]} м/с"
    end
  end

end