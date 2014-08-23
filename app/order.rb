#Refreshes the Starting order by replacing existing order with given order
#Params:
# - starting_order - ordered list of usernames
# - users - hash of username to user mapping
def refresh_starting_order(starting_order, users)
    OrderEntry.delete_all
    starting_order.each_with_index do |name, index|
        OrderEntry.create(user: users[name], order: index)
    end
end
