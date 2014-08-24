require 'date'
require 'holidays'

#Extending Date class with utility methods useful for finding the next day in schedule
class Date

    #Just the US holiday names for a date
    def us_holiday_names
        return Holidays.on(self, :us, :observed).map {|holiday| holiday[:name]}
    end

    #Method to find out if date is a California Holiday.
    #California observes the same holidays as the US Federal government,
    #except it also declares Cezar Chavez Day and the day after Thanksgiving
    #as holidays and Columbus Day is not a holiday.
    #Details from - http://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/#url=2014
    #https://www.ftb.ca.gov/aboutFTB/holidays.shtml
    def ca_holiday?

        if month == 3 and day == 31 #Cesar Chavez Day, not handled by Holidays
            return true
        end

        if prev_day.us_holiday_names.include? "Thanksgiving" #Day after Thanksgiving, not a Federal holiday
            return true
        end

        #Any federal holiday except Coloumbus day is a California holiday
        if not us_holiday_names.empty? and not us_holiday_names.include? "Columbus Day"
            return true
        end

        return false
    end

    def weekend?
        return (saturday? or sunday?)
    end


    #Skip weekends and CA holidays to only get schedulable days
    def next_schedule_day
        date = self
        while date.weekend? or date.ca_holiday?
            date = date.next
        end
        return date
    end

    def self.clean_parse(date_str)
        begin
            return parse(date_str)
        rescue ArgumentError => e
            return false
        end
    end
end 

if __FILE__ == $0
    print Date.civil(2014, 8, 23).ca_holiday?, " Aug 23rd 2014 - not a California Holiday. Next day in schedule ", Date.civil(2014, 8, 23).next_schedule_day, "\n"
    print Date.civil(2014, 1, 1).ca_holiday?, " Jan 1 \n"
    print Date.civil(2014, 3, 31).ca_holiday?, " Cezar Chavez day \n"
    print Date.civil(2014, 11, 28).ca_holiday?, " Day afer thanksgiving \n"
    print Date.civil(2014, 11, 27).ca_holiday?, " Aug 27 thanksgiving. Next day in schedule ", Date.civil(2014, 11, 27).next_schedule_day, "\n"
    print Date.civil(2014, 10, 13).ca_holiday?, " Columbus Day \n"
end
