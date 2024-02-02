class DateSeriesWithValidationService
  attr_reader :relation, :date_start, :date_end, :interval, :aggregation

  def initialize(relation:, date_start:, date_end:, interval:, aggregation:)
    @relation = relation
    @date_start = Date.parse(date_start) rescue nil
    @date_end = Date.parse(date_end) rescue nil
    @interval = interval
    @aggregation = aggregation
  end

  def to_h
    generate_series.to_h { |row| [row["date"].to_date, row["value"]] }
  end

  private

  def generate_series
    filter_dates
    aggregate_data
    group_by_interval
  end

  def filter_dates
    @relation = @relation.where(created_at: @date_start..@date_end) if @date_start && @date_end
  end

  def aggregate_data
    case @aggregation
    when :min, :max, :avg, :sum
      @relation = @relation.select("#{interval_trunk_func}, #{@aggregation}(magnitude) AS value")
    else
      raise ArgumentError, "Invalid aggregation function: #{@aggregation}"
    end
  end

  def group_by_interval
    case @interval
    when :day, :week, :month, :year
      @relation = @relation.group(interval_trunk_func).order("date")
    else
      raise ArgumentError, "Invalid interval: #{@interval}"
    end
  end

  def interval_trunk_func
    "DATE_TRUNC('#{@interval}', created_at)"
  end
end