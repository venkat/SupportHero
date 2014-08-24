#!/usr/bin/env ruby

require 'active_record'
require 'sqlite3'
require 'slop'
require './app/models/user'
require './app/models/order_entry'
require './app/user'
require './app/order'
require './app/command_processor'
require 'date'

dbconfig = YAML.load(File.read('config/database.yml'))
env = ENV['RACK_ENV'] || 'development'
ActiveRecord::Base.establish_connection dbconfig[env]


def parse_opts
    opts = Slop.parse help: true do
        banner 'Usage: ./hero.rb command [options]'


        command 'set-order' do
            description 'Set a new starting order or overwite the stored starting order'

            on :orderfile=, 'Path to the file with the starting order listed, one name per line. New names will create a user if a user with that name is not present'

            run do |opts, args|
                Commands.set_order opts.to_hash
            end
        end

        command 'list-order' do
            description 'List the given starting order'

            run do |opts, args|
                Commands.list_order
            end
        end

        command 'make-schedule' do
            description 'Generates the Scheduled based on the stored starting order'
            on :startdate=, 'When to start the schedule from. Defaults to starting from end of current schedule. Overwrites existing assignments'

            run do |opts, args|
                Commands.make_schedule opts.to_hash
            end
        end

        command 'list-schedule' do
            description 'List the schedule for the next 30 days for everyone or just one user'

            on :username=, "Username for the user whose scheduled needs to be listed. No username implies all users"

            run do |opts, args|
                Commands.list_schedule opts.to_hash
            end
        end

        command 'support-hero' do
            description "Support Hero of the day"

            run do |opts, args|
                Commands.show_support_hero
            end
        end

        command 'off-duty' do
            description "Mark a user's on-duty day as undoable"
            
            on :username=, "Username for the user whose on-duty day is being marked undoable"
            on :offdate=, "Date (example, March 3rd 2014) which is undoable by the user"

            run do |opts, args|
                Commands.mark_off_duty opts.to_hash
            end
        end

        command 'swap-days' do
            description "Swap the days between swapper and swappee"
    
            on :swapper=, "Username of Swapper, person initiating the swap"
            on :swapper_date=, "Date swapper wants to relenquish"
            on :swappee=, "Username of Swappee, person date is being swapped with"
            on :swappee_date=, "Date of swappee"

            run do |opts, args|
                Commands.make_date_swap(opts.to_hash)
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
