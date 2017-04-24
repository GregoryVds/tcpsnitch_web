class SocketTracesController < ApplicationController
  def show
    @socket_trace = SocketTrace.find(params[:id])
    @stat_categories = StatCategory.left_menu(@socket_trace.analysable_type)
    @analysis = @socket_trace.analysis
    @events = Event.only(:details, :errno, :return_value, :success,
                         :timestamp_usec, :thread_id, :type)
                   .where(socket_trace_id: params[:id])
                   .order(index: :asc).page(params[:page])
  end
end
