class EventsController < ApplicationController
  def index
    @socket_trace = SocketTrace.find(params[:socket_trace_id])
    @events = Event.only(:details, :errno, :return_value, :success, :timestamp_usec, :thread_id, :type)
                   .where(socket_trace_id: params[:socket_trace_id])
                   .order(index: :asc).paginate(page: params[:page], per_page: 30)
  end
end
