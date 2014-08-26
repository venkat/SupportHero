require 'test_helper'
require 'timecop'

class ScheduleTest < ActiveSupport::TestCase

    def teardown
        Schedule.destroy_all
        ScheduledTillDate.destroy_all
    end

    test "make schedule" do
        Schedule.extend(from: Date.new(2014, 8, 20))
        expected = [[20, 'A'], [21, 'B'], [22, 'A'], [25, 'A'], [26, 'C'], [27, 'C'], [28, 'B'], [29, 'C']]
        expected = expected.map { |row| [Date.new(2014, 8, row[0]), row[1]] }
        result = Schedule.list()
        result = result.map { |row| [row.date, row.user.name] }
        assert expected == result
    end

    test "support hero" do
        test_date = Date.new(2014, 8, 20)
        Schedule.extend(from: test_date)
        Timecop.freeze(2014, 8, 21, 12, 0, 0)
        support_hero = Schedule.support_hero
        assert support_hero.user.name == 'B' and support_hero.date == test_date
        Timecop.return
    end

end
