class OrderEntry < ActiveRecord::Base
    belongs_to :user

    def self.starting_order
        return order(order: :asc)
    end

    #Refreshes the Starting order by replacing existing order with given order
    #Params:
    # - starting_order - ordered list of usernames
    # - users - hash of username to user mapping
    def self.refresh(starting_order, users)
        delete_all
        starting_order.each_with_index do |name, index|
            create(user: users[name], order: index)
        end
    end
end
