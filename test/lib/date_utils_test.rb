require "minitest/autorun"
require "./lib/date_utils"

class TestDateUtils < Minitest::Test

    def test_weekend
        assert_equal Date.new(2014, 8, 23).weekend?, true
        assert_equal Date.new(2014, 8, 25).weekend?, false
    end

    def test_holiday
        assert_equal Date.new(2014, 1, 1).ca_holiday?, true #New Year's
        assert_equal Date.new(2014, 3, 31).ca_holiday?, true #Cezar Chavez
        assert_equal Date.new(2014, 11, 28).ca_holiday?, true #Day after thanksgiving
        assert_equal Date.new(2014, 11, 27).ca_holiday?, true #Thanksgiving
        assert_equal Date.new(2014, 10, 13).ca_holiday?, false #Columbus Day
        assert_equal Date.new(2014, 8, 23).ca_holiday?, false 
    end

    def test_next_schedule_day
        assert_equal Date.new(2014, 11, 27).next_schedule_day, Date.new(2014, 12, 1)
        assert_equal Date.new(2014, 8, 23).next_schedule_day, Date.new(2014, 8, 25)
        assert_equal Date.new(2014, 8, 25).next_schedule_day, Date.new(2014, 8, 25)
    end 
end
