namespace :custom do
  desc 'Replace in database missing constants'
  task :missing_constants => :environment do
    events = Event.in(type: [:socket, :forked_socket, :ghost_socket, :accept, :accept4, :dup, :dup2, :dup3, :fcntl])
    proto = 'details.sock_info.protocol'
    events.where(proto => 0).update_all(proto => '0')
    events.where(proto => '1').update_all(proto => 'icmp')
    events.where(proto => '6').update_all(proto => 'tcp')
    events.where(proto => '17').update_all(proto => 'udp')

    events = Event.in(type: [:getsockopt, :setsockopt])
    level = 'details.level'
    events.where(level => '255').update_all(level => 'SOL_RAW')
    events.where(level => '263').update_all(level => 'SOL_PACKET')
    events.where(level => 'IPPROTO_TCP').update_all(level => 'SOL_TCP')
    events.where(level => 'IPPROTO_UDP').update_all(level => 'SOL_UDP')
    events.where(level => 'IPPROTO_IP').update_all(level => 'SOL_IP')
    events.where(level => 'IPPROTO_IPV6').update_all(level => 'SOL_IPV6')
  end
end
