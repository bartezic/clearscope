class PlotsController < ApplicationController
  layout -> { ApplicationLayout }

  def index
    # strong params not working in ruby 3.2 as keywords for arguments, can't use next syntacsys:
    # date_series = DateSeriesService.new(**data_params, relation: Point.all)
    date_series = DateSeriesService.new(
      relation: Point.all,
      date_start: data_params[:date_start],
      date_end: data_params[:date_end],
      interval: data_params[:interval],
      aggregation: data_params[:aggregation],
    ).to_h

    if date_series.empty?
      render Plots::NoDataView
      return
    end

    render Plots::IndexView.new(date_series)
  end

  private

  def data_params
    params.permit(:date_start, :date_end, :interval, :aggregation).tap do |pms|
      pms[:aggregation] = 'avg' if pms[:aggregation] == 'average'
    end
  end
end
