
def f(val, x)
    val.to_s.ljust(x)
end

namespace :custom do
  desc 'TCP_INFO'
  task :tcp_info => :environment do
    sockets = []
    Analysis.batch_size(500).where(analysable_type: :socket_trace, os: 1, socket_type: 1).each do |a|
        next unless a[:measures]["getsockopt() optname args"].map(&:first).include?("TCP_INFO")
        app = SocketTrace.find(a.analysable_id).app_trace.app
        tcp_info_count = a[:measures]["getsockopt() optname args"].select{|o,c| o.eql?("TCP_INFO")}.first.last
        send_calls = a[:measures]["Functions calls"].select{|f,c| ["send", "sendto", "write", "sendmsg", "writev"].include?(f)}.map(&:last).sum
        recv_calls = a[:measures]["Functions calls"].select{|f,c| ["recv", "recvfrom", "read", "readmsg", "readv"].include?(f)}.map(&:last).sum
        sockets.push([app, tcp_info_count, send_calls, recv_calls])
    end


    puts f("APP",30) + f("#TCP_INFO",10) + f("#SEND",10) + f("#RECV",10)
    sockets.each do |sock|
        puts f(sock[0],30) + f(sock[1],10) + f(sock[2] ? sock[2] : 0,10) + f(sock[3] ? sock[3] : 0,10)
    end
  end
end
