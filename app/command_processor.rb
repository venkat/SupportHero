require './app/models/order_entry'
require './app/models/scheduled_till_date'
require './app/models/user'
require './app/models/schedule'
require './app/date_utils'

#Methods that process the different commands supported by the client
class Commands
    def self.set_order(opts)
        if opts[:orderfile].nil?
            puts "Path to the starting order file needed"
            return
        end

        #TODO: check if starting order is non-empty, valid content
        starting_order = File.open(opts[:orderfile]).readlines.each { |line| line.strip! }
        usernames = starting_order.uniq 
        users = User.add_missing(usernames)
        OrderEntry.refresh(starting_order, users)
        puts "Starting Order processed and Schedule update starting from today."
    end

    def self.list_order
        puts "Given starting order:"
        puts "Order\tUser"
        OrderEntry.starting_order.each{|order| puts "#{order.order}\t#{order.user.name}"}
    end

    def self.make_schedule(opts)

        date = nil
        if not opts[:startdate].nil?
            date = Date.clean_parse(opts[:startdate])
            if date.nil?
                puts "Invalid date format"
                return
            end
        end
        
        Schedule.extend(from: date)

        puts "Schedule created successfully"
    end
        
    def self.list_schedule(opts)
        user = nil
        if not opts[:username].nil?
            user = User.where(name: opts[:username])
        end

        puts "Schedule for the next 30 days:"
        puts "Date\tUser"
        Schedule.list(user).each do |schedule|
            puts "#{schedule.date}\t#{schedule.user.name}"
        end
    end

    def self.show_support_hero

        hero = Schedule.support_hero
        if hero.nil?
            puts "No one is on-duty today"
        else
            puts "#{hero.user.name} is Support Hero of the day!"
        end
    end

    def self.mark_off_duty(opts)
        if opts[:username].nil?
            puts "Username needed."
            return
        end
        if opts[:offdate].nil?
            puts "Off date needs to be specified."
            return
        end

        date = Date.clean_parse(opts[:offdate])
        if date.nil?
            puts "Invalid date format."
            return
        end

        if date <= Date.today
            puts "Must pick a date in the future"
            return
        end

        user = User.where(name: opts[:username]).first
        message = Schedule.off_day(user, date)
        if not message.nil?
            puts "#{message}"
        else
            #TODO: List the changes here
            puts "Off day set. Please look at the updated schedule"
        end
    end

    def self.make_date_swap(opts)
        if opts[:swapper].nil? or opts[:swappee].nil?
            puts "Username needed for both swapper and swappee."
            return
        end

        if opts[:swapper_date].nil? or opts[:swappee_date].nil?
            puts "Dates needed for both swapper and swappee."
            return
        end

        swapper_date = Date.clean_parse(opts[:swapper_date])
        swappee_date = Date.clean_parse(opts[:swappee_date])
        if swapper_date.nil? or swappee_date.nil?
            puts "Both Swapper and Swappee dates must be in valid format."
        end
        if swapper_date <= Date.today or swappee_date <= Date.today
            puts "Must pick a date in the future."
        end

        swapper = User.where(name: opts[:swapper]).first
        swappee = User.where(name: opts[:swappee]).first
        message = Schedule.swap(swapper, swapper_date, swappee, swappee_date)  
        if not message.nil?
            puts "#{message}"
        else
            puts "Days swapped. Please look at the updated schedule."
        end
    end
end
