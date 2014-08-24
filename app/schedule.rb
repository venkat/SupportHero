require './app/user'
require './app/models/schedule'
require './app/date_utils'
require 'date'
    
#Assign users to the schedule by starting order but for only schedulable days

def schedule_list(user = nil)
    if user.nil?
        schedule_days = Schedule.all
    else
        schedule_days = Schedule.where(user: user)
    end
    return schedule_days.limit(30)
end

#Find who is today's on-duty user
def support_hero
    return Schedule.where(date: Date.today).first 
end

#Handle user making their day as not doable. Currently swaps with
#another random user. Swapping with the next schedule date might be a better
#approach. TODO and open for discussion. Also, the marked days are not
#stored so it also possible that if enough swappings happen, someone might
#get swapped into a day they intially marked a not doable (TODO).
def off_day(user, date)
    user_schedule = Schedule.where(user: user, date: date).first
    if user_schedule.nil?
        return "No schedule for user on that date"
    end

    swappable_schedules = Schedule.where.not(user: user)
    if swappable_schedules.nil?
        return "No other days available to swap with"
    end

    offset = rand(swappable_schedules.count)
    swappable_schedule = swappable_schedules[offset]
    user_schedule.user = swappable_schedule.user
    user_schedule.save
    swappable_schedule.user = user
    swappable_schedule.save

    return nil
end

#Swap schedules
#Params:
# Swapper - Person initiating the swap
# Swappee - Person with whom the schedule is being swapped
def swap_schedules(swapper, swapper_date, swappee, swappee_date)
    swapper_schedule = Schedule.where(user: swapper, date: swapper_date).first
    swappee_schedule = Schedule.where(user: swappee, date:swappee_date).first
    
    if swapper_schedule.nil? or swappee_schedule.nil?
        return "Invalid User or Date given"
    end
    
    tmp_user = swapper_schedule.user
    swapper_schedule.user = swappee_schedule.user
    swappee_schedule.user = tmp_user
    swapper_schedule.save
    swappee_schedule.save
    return nil
end

def get_date(date_str)
    begin
        return Date.parse(date_str)
    rescue ArgumentError => e
        return false
    end
end
