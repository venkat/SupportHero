require 'date'
require 'holidays'
require 'minitest/assertions'

# Extending Date class with utility methods useful for finding the next day in schedule
class Date

    # Returns just the US holiday names for a date
    def us_holiday_names
        return Holidays.on(self, :us, :observed).map {|holiday| holiday[:name]}
    end

    # Returns true if date is a California Holiday.
    # California observes the same holidays as the US Federal government,
    # except it also declares Cezar Chavez Day and the day after Thanksgiving
    # as holidays and Columbus Day is not a holiday.
    # Details from - http://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/#url=2014
    # https://www.ftb.ca.gov/aboutFTB/holidays.shtml
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

    # Returns true if date is a weekend
    def weekend?
        return (saturday? or sunday?)
    end


    # Returns the given date if the date is not a weekend or CA holiday
    # otherwise, skips over those and returns the next scheduleable date
    def next_schedule_day
        date = self
        while date.weekend? or date.ca_holiday?
            date = date.next
        end
        return date
    end

end 
