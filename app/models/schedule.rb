require './app/models/scheduled_till_date'
require './app/date_utils'

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
        if from.nil?
            from = ScheduledTillDate.schedule_till
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
            from = schedule_till.next
            break if to.nil? or schedule_till >= to
        end
    end
end
