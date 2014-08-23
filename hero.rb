#!/usr/bin/env ruby

require 'active_record'
require 'sqlite3'
require 'slop'
require './app/models/user'
require './app/models/order_entry'
require './app/user'
require './app/order'
require './app/schedule'
require 'date'

dbconfig = YAML.load(File.read('config/database.yml'))
env = ENV['RACK_ENV'] || 'development'
ActiveRecord::Base.establish_connection dbconfig[env]

def set_order(opts)
    if opts[:orderfile].nil?
        print "Path to the starting order file needed\n"
        return
    end

    #TODO: check if starting order is non-empty, valid content
    #TODO: handle startdate and make sure it is in the future
    starting_order = File.open(opts[:orderfile]).readlines.each { |line| line.strip! }
    usernames = starting_order.uniq 
    users = add_missing_users(usernames)
    refresh_starting_order(starting_order, users)
    generate_schedule(starting_order, Date.today)
    print "Starting Order processed and Schedule update starting from today.\n"
end

def list_order
    print "Given starting order:\n"
    print "Order\tUser\n"
    OrderEntry.all.order(:order).each{|order| print "#{order.order}\t#{order.user.name}\n"}
end

def list_schedule(opts)
    if not opts[:username].nil?
        user = User.where(name: opts[:username])
    else
        user = nil
    end

    print "Schedule for the next 30 days:\n"
    print "Date\tUser\n"
    schedule_list(user).each do |schedule|
        print "#{schedule.date}\t#{schedule.user.name}\n"
    end
end

def show_support_hero
    hero = support_hero
    if hero.nil?
        print "No one is on-duty today\n"
    else
        print "#{hero.user.name} is Support Hero of the day!\n"
    end
end

def mark_off_duty(opts)
    if opts[:username].nil?
        print "Username needed.\n"
        return
    end
    if opts[:offdate].nil?
        print "Off date needs to be specified.\n"
        return
    end

    date = get_date(opts[:offdate])
    if date.nil?
        print "Invalid date format.\n"
        return
    end

    if date <= Date.today
        print "Must pick a date in the future\n"
        return
    end

    user = User.where(name: opts[:username]).first
    message = off_day(user, date)
    if not message.nil?
        print "#{message}\n"
    else
        #TODO: List the changes here
        print "Off day set. Please look at the updated schedule\n"
    end
end

def make_date_swap(opts)
    if opts[:swapper].nil? or opts[:swappee].nil?
        print "Username needed for both swapper and swappee. \n"
        return
    end

    if opts[:swapper_date].nil? or opts[:swappee_date].nil?
        print "Dates needed for both swapper and swappee. \n"
        return
    end

    swapper_date = get_date(opts[:swapper_date])
    swappee_date = get_date(opts[:swappee_date])
    if swapper_date.nil? or swappee_date.nil?
        print "Both Swapper and Swappee dates must be in valid format.\n"
    end
    if swapper_date <= Date.today or swappee_date <= Date.today
        print "Must pick a date in the future\n"
    end

    swapper = User.where(name: opts[:swapper]).first
    swappee = User.where(name: opts[:swappee]).first
    message = swap_schedules(swapper, swapper_date, swappee, swappee_date)  
    if not message.nil?
        print "#{message}\n"
    else
        print "Days swapped. Please look at the updated schedule.\n"
    end
end

def parse_opts
    opts = Slop.parse help: true do
        banner 'Usage: ./hero.rb command [options]'


        command 'set-order' do
            description 'Set a new starting order'

            on :orderfile=, 'Path to the file with the starting order listed, one name per line. New names will create a user if a user with that name is not present'
            on :startdate=, 'Date when this starting order becomes active. If not specified, the next open date in the schedule is used'

            run do |opts, args|
                set_order opts.to_hash
            end
        end

        command 'list-order' do
            description 'List the given starting order'

            run do |opts, args|
                list_order
            end
        end

        command 'list-schedule' do
            description 'List the schedule for the next 30 days for everyone or just one user'

            on :username=, "Username for the user whose scheduled needs to be listed. No username implies all users"

            run do |opts, args|
                list_schedule opts.to_hash
            end
        end

        command 'support-hero' do
            description "Support Hero of the day"

            run do |opts, args|
                show_support_hero
            end
        end

        command 'off-duty' do
            description "Mark a user's on-duty day as undoable"
            
            on :username=, "Username for the user whose on-duty day is being marked undoable"
            on :offdate=, "Date (example, March 3rd 2014) which is undoable by the user"

            run do |opts, args|
                mark_off_duty opts.to_hash
            end
        end

        command 'swap-days' do
            description "Swap the days between swapper and swappee"
    
            on :swapper=, "Username of Swapper, person initiating the swap"
            on :swapper_date=, "Date swapper wants to relenquish"
            on :swappee=, "Username of Swappee, person date is being swapped with"
            on :swappee_date=, "Date of swappee"

            run do |opts, args|
                make_date_swap(opts.to_hash)
            end
        end
    end
end

if __FILE__ == $0
    if ARGV.empty?
        print parse_opts
    else
        opts = parse_opts
    end
end
