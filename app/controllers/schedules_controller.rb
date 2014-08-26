class SchedulesController < ApplicationController
    respond_to :json
    def index
        username = params[:username]
        user = User.where(name: username)
        schedules = Schedule.list(user).map { |schedule| {date: schedule.date, user: schedule.user} }
        respond_with schedules
    end

    def support_hero
        hero = Schedule.support_hero
        respond_with hero do |format|
            format.json {render :json => hero.to_json(:include => :user) }
        end
    end 

    def extend
        from = params[:from] 
        to = params[:to]
        from &&= Date.parse(from)
        to &&= Date.parse(to)

        Schedule.extend(from: from, to: to)

        respond_to do |format|
            format.json {render :json => {status: true}}
        end
    end

    def off_day
        username = params[:username]
        date = Date.parse(params[:date])
        message = Schedule.off_day(username, date)
        respond_to do |format|
            format.json {render :json => {message: message}}
        end
    end

    def swap
        swapper = params[:swapper]
        swappee = params[:swappee]
        swapper_date = Date.parse(params[:swapper_date])
        swappee_date = Date.parse(params[:swappee_date])
        swapper = User.where(name: swapper).first
        swappee = User.where(name: swappee).first
        message = Schedule.swap(swapper, swapper_date, swappee, swappee_date)
        respond_to do |format|
            format.json {render :json => {message: message}}
        end
    end
end
