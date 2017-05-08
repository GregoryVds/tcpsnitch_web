class AddSocketDomainToSocketTraces < ActiveRecord::Migration[5.0]
  class SocketTrace < ActiveRecord::Base
    enum socket_type: {SOCK_DGRAM: 0, SOCK_STREAM: 1, SOCK_RAW: 2}
    enum socket_domain: {AF_PACKET: 0, AF_INET: 1, AF_INET6: 2}
  end

  def up
    add_column :socket_traces, :socket_domain, :integer
    add_column :socket_traces, :remote_con, :boolean
    add_column :app_traces, :network_specialized_app, :boolean, default: false

    SocketTrace.reset_column_information
    SocketTrace.all.each do |socket_trace|
      connect = Event.where(type: :connect, socket_trace_id: socket_trace.id).first
      # remote_con
      remote_con = if connect.nil?
        false
      else
        addr = Addrinfo.ip(connect.details[:addr][:ip])
        not(addr.ipv4_loopback? or addr.ipv6_loopback?)
      end
      socket_trace.remote_con = remote_con

      # socket_domain
      domain = Event.where(index: 0, socket_trace_id: socket_trace.id).first.details[:sock_info][:domain]
      socket_trace.socket_domain = domain

      socket_trace.save!

      # Update events
      Event.where(socket_trace_id: socket_trace.id).update_all({
        socket_domain: domain,
        remote_con: remote_con,
        socket_type: socket_trace.socket_type
      })
    end

    AppTrace.all.each do |app_trace|
      if ["traceroute", "iperf3", "nmap"].include?(app_trace.app)
        app_trace.network_specialized_app = true
        Event.where(app_trace_id: app_trace.id).update_all(network_specialized_app: true)
      end
    end
  end

  def down
    remove_column :socket_traces, :socket_domain
    remove_column :socket_traces, :remote_con
  end
end
