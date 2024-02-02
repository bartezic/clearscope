class DateSeriesService
  INTERVALS = ['day', 'week', 'month', 'year']
  AGGREGATIONS = ['avg', 'sum', 'max', 'min']

  attr_reader :relation, :date_start, :date_end, :interval, :aggregation

  def initialize(relation:, date_start:, date_end:, interval:, aggregation:)
    @relation = relation
    @date_start = Date.parse(date_start) rescue Date.today.beginning_of_year
    @date_end = Date.parse(date_end) rescue Date.today.end_of_day
    @interval = interval.in?(INTERVALS) ? interval : INTERVALS.first
    @aggregation = aggregation.in?(AGGREGATIONS) ? aggregation : AGGREGATIONS.first
  end

  def to_h
    generate_series.to_h { |row| [row["date"].to_date, row["value"]] }
  end

  private

  def generate_series
    @relation
      .where(created_at: @date_start..@date_end)
      .select("#{interval_trunk_func} AS date, #{@aggregation}(magnitude) AS value")
      .group(interval_trunk_func)
      .order('date')
  end

  def interval_trunk_func
    "DATE_TRUNC('#{@interval}', created_at)"
  end
end
