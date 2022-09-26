require 'json'
require './app/services/github_service'
require './app/services/holiday_service'


class HolidayFacade

  def self.next_3_holidays
    response = HolidayService.request
    holiday_names = []
    i = 0
    until holiday_names.size == 3 do
      holiday_names << response[i]["localName"]
      i += 1
    end
    holiday_names
  end
  
end