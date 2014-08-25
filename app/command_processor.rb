require 'rest_client'

#Methods that process the different commands supported by the client
class Commands
    def initialize(api_url)
        @api_url = api_url
    end

    def self.clean_parse(date_str)
        begin
            return Date.parse(date_str)
        rescue ArgumentError => e
            return false
        end
    end

    def set_order(opts)
        if opts[:orderfile].nil?
            puts "Path to the starting order file needed"
            return
        end

        #TODO: check if starting order is non-empty, valid content
        starting_order = File.open(opts[:orderfile]).readlines.each { |line| line.strip! }
        usernames = starting_order.uniq 
        RestClient.post "#{@api_url}/users/add_missing", {usernames: usernames}.to_json, content_type: :json, accept: :json
        RestClient.post "#{@api_url}/order_entries/refresh", {order_entries: starting_order}.to_json, content_type: :json, accept: :json
        puts "Starting Order updated."
    end

    def list_order
        puts "Given starting order:"
        puts "Order\tUser"
        response = RestClient.get "#{@api_url}/order_entries", accept: :json
        starting_order = JSON.parse(response)
        starting_order.each{|order| puts "#{order["order"]}\t#{order["user"]["name"]}"}
    end

    def make_schedule(opts)

        date = nil
        if not opts[:startdate].nil?
            date = clean_parse(opts[:startdate])
            if date.nil?
                puts "Invalid date format"
                return
            end
        end
        
        params = {from: date}
        RestClient.get "#{@api_url}/schedules/extend", {params: params}
        puts "Schedule created successfully"
    end
        
    def list_schedule(opts)
        params = nil
        if not opts[:username].nil?
            params = {:username => opts[:username]}
        end

        schedules = RestClient.get "#{@api_url}/schedules" , {:params => params}
        puts "Schedule for the next 30 days:"
        puts "Date\tUser"
        JSON.parse(schedules).each do |schedule|
            puts "#{schedule["date"]}\t#{schedule["user"]["name"]}"
        end
    end

    def show_support_hero

        hero = RestClient.get "#{@api_url}/schedules/support_hero"
        if hero.nil? or hero.empty? or hero == 'null'
            puts "No one is on-duty today"
        else
            hero = JSON.parse(hero)
            puts "#{hero["user"]["name"]} is Support Hero of the day!"
        end
    end

    def mark_off_duty(opts)
        if opts[:username].nil?
            puts "Username needed."
            return
        end
        if opts[:offdate].nil?
            puts "Off date needs to be specified."
            return
        end

        date = clean_parse(opts[:offdate])
        if date.nil?
            puts "Invalid date format."
            return
        end

        if date <= Date.today
            puts "Must pick a date in the future"
            return
        end

        params = {username: opts[:username], date: date}
        response = RestClient.get "#{@api_url}/schedules/off_day", params: params
        message = JSON.parse(response)["message"]
        if not message.nil?
            puts message
        else
            #TODO: List the changes here
            puts "Off day set. Please look at the updated schedule"
        end
    end

    def make_date_swap(opts)
        if opts[:swapper].nil? or opts[:swappee].nil?
            puts "Username needed for both swapper and swappee."
            return
        end

        if opts[:swapper_date].nil? or opts[:swappee_date].nil?
            puts "Dates needed for both swapper and swappee."
            return
        end

        swapper_date = clean_parse(opts[:swapper_date])
        swappee_date = clean_parse(opts[:swappee_date])
        if swapper_date.nil? or swappee_date.nil?
            puts "Both Swapper and Swappee dates must be in valid format."
        end
        if swapper_date <= Date.today or swappee_date <= Date.today
            puts "Must pick a date in the future."
        end

        params = {
                  swapper: opts[:swapper],
                  swappee: opts[:swappee],
                  swapper_date: swapper_date,
                  swappee_date: swappee_date,
                 }
        response = RestClient.get "#{@api_url}/schedules/swap", params: params
        message = JSON.parse(response)["message"]
        if not message.nil?
            puts message
        else
            puts "Days swapped. Please look at the updated schedule."
        end
    end
end
