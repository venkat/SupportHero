class ScheduledTillDate < ActiveRecord::Base
    def self.schedule_till
        date = ScheduledTillDate.first
        date &&= date.date
        date ||= Date.today
        return date
    end
    def self.extend?(date)
        date_till = ScheduledTillDate.first
        date_till &&= date_till.date
        if date_till.nil? or date_till < date
            return true
        else
            return false
        end
    end
end
