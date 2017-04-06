class SocketTracesController < ApplicationController
  def show
    @socket_trace = SocketTrace.find(params[:id])
  end
end
