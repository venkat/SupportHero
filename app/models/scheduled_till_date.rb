class ScheduledTillDate < ActiveRecord::Base
    # Returns the last date till which the schedule was
    # generated.
    def self.schedule_till
        date = ScheduledTillDate.first
        date &&= date.date
        return date
    end

    # Returns true if the schedule needs to be extended to
    # the given date (that is, the schedule has not yet been
    # generated till that date)
    def self.extend?(date)
        date_till = schedule_till
        if date_till.nil? or date_till < date
            return true
        else
            return false
        end
    end
end
