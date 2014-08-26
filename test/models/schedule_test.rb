require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

   test "make schedule" do
        Schedule.extend(from: Date.new(2014, 8, 20))
        expected = [[20, 'A'], [21, 'B'], [22, 'A'], [25, 'A'], [26, 'C'], [27, 'C'], [28, 'B'], [29, 'C']]
        expected = expected.map { |row| [Date.new(2014, 8, row[0]), row[1]] } 
        result = Schedule.list()
        result = result.map { |row| [row.date, row.user.name] }
        assert expected == result 
   end

end
