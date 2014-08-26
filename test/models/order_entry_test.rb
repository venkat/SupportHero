require 'test_helper'

class OrderEntryTest < ActiveSupport::TestCase
    test "starting order" do
        order_count = OrderEntry.starting_order.count
        OrderEntry.create({order: order_count, user: User.find_by(name: 'A')})
        entry = OrderEntry.starting_order.last
        assert entry.order == order_count && entry.user.name == 'A'
    end

    # Tests by creating a modified version of the existing order
    # and verfies refresh sets the new order to be the modified version
    test "the order refresh" do
        existing = OrderEntry.starting_order.map {|order| order.user.name}
        new = existing[0..-2].reverse
        OrderEntry.refresh(new)
        assert new == OrderEntry.starting_order.map {|order| order.user.name} 
    end
end
