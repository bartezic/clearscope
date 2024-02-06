require 'test_helper'

class DateSeriesWithValidationServiceTest < ActiveSupport::TestCase
  def setup
    @relation = Minitest::Mock.new
  end

  test 'initialize with valid parameters' do
    service = DateSeriesWithValidationService.new(relation: @relation, date_start: '2023-01-01', date_end: '2023-12-31', interval: :month, aggregation: :sum)
  
    assert_equal Date.parse('2023-01-01'), service.date_start
    assert_equal Date.parse('2023-12-31'), service.date_end
    assert_equal :month, service.interval
    assert_equal :sum, service.aggregation
  end

  test 'initialize with invalid parameters' do
    service = DateSeriesWithValidationService.new(relation: @relation, date_start: 'invalid_date', date_end: 'invalid_date', interval: :day, aggregation: :avg)
  
    assert_nil service.date_start
    assert_nil service.date_end
    assert_equal :day, service.interval
    assert_equal :avg, service.aggregation
  end

  test 'initialize with invalid interval raises ArgumentError' do
    assert_raises(ArgumentError, "Invalid interval: invalid_interval") do
      DateSeriesWithValidationService.new(relation: @relation, date_start: '2023-01-01', date_end: '2023-12-31', interval: :invalid_interval, aggregation: :sum)
    end
  end

  test 'initialize with invalid aggregation raises ArgumentError' do
    assert_raises(ArgumentError, "Invalid aggregation function: invalid_aggregation") do
      DateSeriesWithValidationService.new(relation: @relation, date_start: '2023-01-01', date_end: '2023-12-31', interval: :month, aggregation: :invalid_aggregation)
    end
  end

  test 'to_h generates series correctly' do
    # Prepare mock relation with expected behavior
    @relation.expect(:where, @relation, [created_at: Date.parse('2023-01-01')..Date.parse('2023-01-02')])
    @relation.expect(:select, @relation, ["DATE_TRUNC('day', created_at), avg(magnitude) AS value"])
    @relation.expect(:group, @relation, ["DATE_TRUNC('day', created_at)"])
    @relation.expect(:order, @relation, ["date"])

    @relation.expect(:to_h, { Date.parse('2023-01-01') => 10, Date.parse('2023-01-02') => 15 })

    service = DateSeriesWithValidationService.new(relation: @relation, date_start: '2023-01-01', date_end: '2023-01-02', interval: :day, aggregation: :avg)
    series = service.to_h

    assert_equal({ Date.parse('2023-01-01') => 10, Date.parse('2023-01-02') => 15 }, series)
  end
end
