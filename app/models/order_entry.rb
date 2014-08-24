class OrderEntry < ActiveRecord::Base
    belongs_to :user

    def self.starting_order
        return order(order: :asc)
    end
end
