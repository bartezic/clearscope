# frozen_string_literal: true

class Plots::IndexView < ApplicationView

  def initialize(date_series)
    @date_series = date_series

    prepare_graph_data if @date_series.any?
  end

  def template
    h1(style: 'text-align: center;') { "Scatterplot" }

    if @date_series.any?
      h2(style: 'text-align: center;') { 'HTML' }
      html_graph
      h2(style: 'text-align: center;') { 'SVG' }
      svg_graph
      div(style: 'height: 50px')
    else
      div { 'No data' }
    end
  end

  def html_graph
    div(style: "width: #{@graph_width}px; height: #{@graph_height}px; margin: 0 auto; border-left: 2px solid #000; position: relative; font-size: 10px") do
      div(style: "width: #{@graph_width}px; height: 2px; position: absolute; bottom: #{@level_of_x_axis}px; background-color: black;") do
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

  def svg_graph
    div(style: "display: flex; justify-content: center; font-size: 10px") do
      svg(style: "overflow: visible;", height: @graph_height, width: @graph_width) do |s|
        s.g do
          @date_series_with_positions.each do |point|
            s.circle(cx: point[:x], cy: @graph_height-point[:y], r: "4", fill: 'blue')
            s.text(x: point[:x]+5, y: @graph_height-point[:y]) { point[:value] }
          end
        end
        s.g(style: "stroke:black; stroke-width: 2;") do
          s.line(x1: 0, y1: @graph_height-@level_of_x_axis, x2: @graph_width, y2: @graph_height-@level_of_x_axis)
          s.line(x1: 0, y1: 0, x2: 0, y2: @graph_height)
        end
        s.g do
          s.text(x: -20, y: @graph_height-@level_of_x_axis) { 0 }
          s.text(x: -20, y: @graph_height) { @min_magnitude.to_i }
          s.text(x: -20, y: 0) { @max_magnitude.to_i }
        end
        s.g do
          s.text(x: 0, y: @graph_height-@level_of_x_axis+10) { @earliest_date.to_s }
          s.text(x: @graph_width-45, y: @graph_height-@level_of_x_axis+10) { @latest_date.to_s }
        end
        s.g do
          s.text(x: @graph_width/2, y: @graph_height+10) { "Time" }
          s.text(style: "transform:rotate(-90deg);", x: @graph_height/-2, y: -10) { "Magnitude" }
        end
      end
    end
  end

  private

  def prepare_graph_data
    # Graph size
    @graph_width = 800
    @graph_height = 400

    # Find the earliest and latest dates
    @earliest_date = @date_series.keys.min
    @latest_date = @date_series.keys.max

    # Calculate the range in days between the earliest and latest dates
    @days_range = (@latest_date - @earliest_date).to_i

    # Find the minimal and maximal magnitudes
    # set minimal magnitude as 0 to display Y axis from 0, not from minimal magnitude
    @min_magnitude = [@date_series.values.min, 0].min
    @max_magnitude = @date_series.values.max

    # Calculate the range in magnitude
    @magnitude_range = @max_magnitude - @min_magnitude

    # For cases we will have negative madnitudes
    @level_of_x_axis = (((0 - @min_magnitude).to_f / @magnitude_range) * @graph_height).round

    # Calculate positions for all date series
    @date_series_with_positions = @date_series.map do |date, magnitude|
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
end
