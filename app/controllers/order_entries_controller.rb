class OrderEntriesController < ApplicationController
    respond_to :json
    def index
        order_entries = OrderEntry.all
        order_entries = order_entries.map { |entry| {order: entry.order, user: entry.user}}
        respond_with order_entries
    end

    def refresh
        OrderEntry.refresh(params[:order_entries])
        respond_to do |format|
            format.json {render :json => {status: true}}
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
