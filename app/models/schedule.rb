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
end
