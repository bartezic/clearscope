# frozen_string_literal: true

class Plots::IndexView < ApplicationView

  def initialize(date_series)
    @date_series = date_series

    # Graph size
    @graph_width = 800
    @graph_height = 400

    # Find the earliest and latest dates
    @earliest_date = date_series.keys.min
    @latest_date = date_series.keys.max

    # Calculate the range in days between the earliest and latest dates
    @days_range = (@latest_date - @earliest_date).to_i

    # Find the minimal and maximal magnitudes
    # set minimal magnitude as 0 to display Y axis from 0, not from minimal magnitude
    @min_magnitude = [date_series.values.min, 0].min
    @max_magnitude = date_series.values.max

    # Calculate the range in magnitude
    @magnitude_range = @max_magnitude - @min_magnitude

    @level_of_x_axis = (((0 - @min_magnitude).to_f / @magnitude_range) * @graph_height).round

    # Calculate positions for all date series
    @date_series_with_positions = date_series.map do |date, magnitude|
      # Calculate position of point on X axis
      relative_x_position = (date - @earliest_date).to_f / @days_range
      position_on_x_axis = (relative_x_position * @graph_width).round

      # Calculate position of point on Y axis
      relative_y_position = (magnitude - @min_magnitude).to_f / @magnitude_range
      position_on_y_axis = (relative_y_position * @graph_height).round

      { date: date, 
        value: magnitude.to_i, 
        x: position_on_x_axis, 
        y: position_on_y_axis }
    end
  end

  def template
    h1 { "Articles index" }

    div(style: "width: #{@graph_width}px; height: #{@graph_height}px; margin: 0 auto; border-left: 1px solid #000; position: relative; font-size: 10px") do
      
      div(style: "width: #{@graph_width}px; height: 1px; position: absolute; bottom: #{@level_of_x_axis}px; background-color: black;") do
        div(style: "position: absolute; left: -5px; bottom: 0; transform: translate(-100%, 0%);") { 0 }
        div(style: "position: absolute; left: 0px; bottom: -13px;") { @earliest_date.to_s }
        div(style: "position: absolute; right: 0px; bottom: -13px;") { @latest_date.to_s }
      end
      
      div(style: "position: absolute; left: -5px; bottom: 0px; transform: translate(-100%, 0%);") { @min_magnitude.to_i }
      div(style: "position: absolute; left: -5px; bottom: #{@graph_height}px; transform: translate(-100%, 0%);") { @max_magnitude.to_i }
      
      @date_series_with_positions.each do |point|
        div(style: "width: 8px; height: 8px; background-color: blue; border-radius: 50%; position: absolute; transform: translate(-50%, -50%); bottom: #{point[:y]}px; left: #{point[:x]}px; font-size: 8px") do
          div(style: "position: absolute; left: 9px") { point[:value] }
        end
      end
    end
  end


end
