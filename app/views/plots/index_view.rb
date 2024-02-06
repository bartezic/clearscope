# frozen_string_literal: true

class Graph < Phlex::HTML
  def initialize(width, height)
    @width = width
    @height = height
  end

  def template(&)
    div(style: "width: #{@width}px; height: #{@height}px; margin: 0 auto; border-left: 2px solid #000; position: relative; font-size: 10px", &)
  end

  def x_axis(level_of_axis, &)
    div(style: "width: #{@width}px; height: 2px; position: absolute; bottom: #{level_of_axis}px; background-color: black;", &)
  end

  def y_axis(&)
    div(&)
  end

  def point(data, &)
    div(style: "width: 8px; height: 8px; background-color: blue; border-radius: 50%; position: absolute; transform: translate(-50%, -50%); bottom: #{data[:y]}px; left: #{data[:x]}px; font-size: 8px") do
      div(style: "position: absolute; left: 9px") { data[:value] }
    end
  end
end

class Plots::IndexView < ApplicationView
  GRAPH_WIDTH = 800
  GRAPH_HEIGHT = 400

  def initialize(date_series)
    @date_series = date_series
  end

  def template
    h1(style: 'text-align: center;') { "Scatterplot" }

    render Graph.new(GRAPH_WIDTH, GRAPH_HEIGHT) do |g|
      g.x_axis(level_of_x_axis) do
        div(style: "position: absolute; left: -5px; bottom: 0; transform: translate(-100%, 0%);") { 0 }
        div(style: "position: absolute; left: 0px; bottom: -13px;") { earliest_date.to_s }
        div(style: "position: absolute; right: 0px; bottom: -13px;") { latest_date.to_s }
      end 
      
      g.y_axis do
        div(style: "position: absolute; left: -5px; bottom: 0px; transform: translate(-100%, 0%);") { min_magnitude.to_i }
        div(style: "position: absolute; left: -5px; bottom: #{GRAPH_HEIGHT}px; transform: translate(-100%, 0%);") { max_magnitude.to_i }
      end
      
      date_series_with_positions.each { |data| g.point(data) }
    end
  end

  private

  def earliest_date
    @date_series.keys.min
  end

  def latest_date
     @date_series.keys.max
  end

  def days_range
    (latest_date - earliest_date).to_i
  end

  def min_magnitude
    [@date_series.values.min, 0].min
  end

  def max_magnitude
    @date_series.values.max
  end

  def magnitude_range
    max_magnitude - min_magnitude
  end

  def level_of_x_axis
    (((0 - min_magnitude).to_f / magnitude_range) * GRAPH_HEIGHT).round
  end

  # Calculate positions for all date series
  def date_series_with_positions
    @date_series.map do |date, magnitude|
      # Calculate position of point on X axis
      relative_x_position = (date - earliest_date).to_f / days_range
      position_on_x_axis = (relative_x_position * GRAPH_WIDTH).round

      # Calculate position of point on Y axis
      relative_y_position = (magnitude - min_magnitude).to_f / magnitude_range
      position_on_y_axis = (relative_y_position * GRAPH_HEIGHT).round

      { date: date, 
        value: magnitude.to_i, 
        x: position_on_x_axis, 
        y: position_on_y_axis }
    end
  end
end
