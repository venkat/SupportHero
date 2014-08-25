class UsersController < ApplicationController
    respond_to :json
    def add_missing
        users = User.add_missing(params[:usernames])
        respond_to  do |format|
            format.json {render :json => users.map {|user| user} }
        end
    end

    #TODO: make client handle CSRF tokens to avoid disabling it for JSON requests
    def verified_request?
        if request.content_type == "application/json"
            true
        else
            super()
        end
    end
end
