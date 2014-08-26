require './app/models/scheduled_till_date'
require './lib/date_utils'

class Schedule < ActiveRecord::Base
  belongs_to :user

    def self.generate(starting_order, start_date)
        cur_date = start_date.next_schedule_day
        schedule_till = nil
        starting_order.each do |order_entry|
            day_schedule = find_or_initialize_by(date: cur_date)
            day_schedule.user = order_entry.user
            day_schedule.save
            schedule_till = cur_date
            cur_date = cur_date.next.next_schedule_day
        end
        return schedule_till
    end

    def self.strip(schedule_till)
        where("date > ?", schedule_till).destroy_all
    end

    def self.extend(from: nil, to: nil)
        if OrderEntry.starting_order.nil?
            return
        end

        if from.nil?
            from = ScheduledTillDate.schedule_till.next
        end
 
        loop do
            schedule_till = Schedule.generate(OrderEntry.starting_order, from)
            Schedule.strip(schedule_till)
            scheduled_till_date = ScheduledTillDate.first
            if scheduled_till_date.nil?
                ScheduledTillDate.create(date: schedule_till)
            else
                scheduled_till_date.update(date: schedule_till)
            end
            break if to.nil? or schedule_till.nil? or schedule_till >= to
            from = schedule_till.next
        end
    end

    def self.list(user=nil)
        if ScheduledTillDate.extend?(Date.today.end_of_month)
            Schedule.extend(to: Date.today.end_of_month)
        end

        if user.nil? or user.empty?
            schedule_days = Schedule.where("date >= ? and date <= ?", Date.today.beginning_of_month, Date.today.end_of_month)
        else
            schedule_days = Schedule.where(user: user).where("date >= ?", Date.today).limit(30)
        end

        return schedule_days.order(date: :asc)
    end

    #Handle user making their day as not doable. Currently swaps with
    #another random user. Swapping with the next schedule date might be a better
    #approach. TODO and open for discussion. Also, the marked days are not
    #stored so it also possible that if enough swappings happen, someone might
    #get swapped into a day they intially marked a not doable (TODO).
    def self.off_day(username, date)
        user = User.where(name: username).first
        if ScheduledTillDate.extend?(date.end_of_month)
            Schedule.extend(to: date.end_of_month)
        end

        user_schedule = where(user: user, date: date).first
        if user_schedule.nil?
            return "No schedule for user on that date"
        end

        swappable_schedules = where.not(user: user)
        swappable_schedules = swappable_schedules.where("date > ?", Date.today)
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

    #Find who is today's on-duty user
    def self.support_hero
        if ScheduledTillDate.extend?(Date.today)
            Schedule.extend(from: Date.today)
        end

        return Schedule.where(date: Date.today).first 
    end

    #Swap schedules
    #Params:
    # Swapper - Person initiating the swap
    # Swappee - Person with whom the schedule is being swapped
    def self.swap(swapper, swapper_date, swappee, swappee_date)

        if ScheduledTillDate.extend?([swapper_date, swappee_date].max)
            Schedule.exend([swapper_date, swappee_date].max)
        end

        swapper_schedule = where(user: swapper, date: swapper_date).first
        swappee_schedule = where(user: swappee, date:swappee_date).first
        
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
end
