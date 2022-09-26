require 'httparty'

class HolidayService
  def self.request
    HTTParty.get('https://date.nager.at/api/v3/NextPublicHolidays/US')
  end
end