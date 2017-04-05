######################
# NATURE OF SOCKETS #
####################
nature_of_sockets_cat = StatCategory.create!(name: 'Nature of sockets', info: 'About the sockets...', parent_category: nil)

# socket()
socket_cat = StatCategory.create!(name: 'At creation of socket', info: 'About the sockets...', parent_category: nature_of_sockets_cat)
[:domain, :type, :protocol, :SOCK_CLOEXEC, :SOCK_NONBLOCK].each do |field|
  Stat.create!({
    apply_to_socket_trace: false,
    event_filters: {type: :socket},
    stat_category: socket_cat,
    stat_type: :proportion,
    name: field, 
    node: "details.sock_info.#{field}"
  })
end

# getsockopt() & setsockopt()
sockopt_cat = StatCategory.create!(name: 'Socket options', info: 'About the socket options usage', parent_category: nature_of_sockets_cat)
sockopt_cat_attr = {
  stat_category: sockopt_cat,
  stat_type: :proportion
}
[[:getsockopt, :setsockopt], [:getsockopt], [:setsockopt]].each do |group|
  Stat.create!(sockopt_cat_attr.merge({event_filters: {type: {'$in': group}}, name: "#{group.join(" & ")} level", node: 'details.level'}))
  Stat.create!(sockopt_cat_attr.merge({event_filters: {type: {'$in': group}}, name: "#{group.join(" & ")} optname", node: 'details.optname'}))
end

# fcntl()
fcntl_cat = StatCategory.create!(name: 'Fcntl', info: 'About the socket options usage', parent_category: nature_of_sockets_cat)
fcntl_cat_attr = {
  stat_category: fcntl_cat,
  stat_type: :proportion
}
Stat.create!(fcntl_cat_attr.merge({event_filters: {type: 'fcntl'}, name: 'Cmd', node: 'details.cmd'}))
Stat.create!(fcntl_cat_attr.merge({event_filters: {type: 'fcntl', 'details.cmd': 'F_GETFD'}, name: 'F_GETFD: O_CLOEXEC', node: 'details.O_CLOEXEC'}))
Stat.create!(fcntl_cat_attr.merge({event_filters: {type: 'fcntl', 'details.cmd': 'F_SETFD'}, name: 'F_SETFD: O_CLOEXEC', node: 'details.O_CLOEXEC'}))
[:F_GETFL, :F_SETFL].each do |cmd|
  [:O_APPEND, :O_ASYNC, :O_DIRECT, :O_NOATIME, :O_NONBLOCK].each do |flag|
    Stat.create!(fcntl_cat_attr.merge({event_filters: {type: 'fcntl', 'details.cmd': cmd}, name: "#{cmd}: #{flag}", node: "details.#{flag}"}))
  end
end

###################
# FUNCTIONS USAGE #
##################
usage_cat = StatCategory.create!(name: 'Functions usage', info: 'About the usage of functions...', parent_category: nil)

# Global usage
global_usage_cat = StatCategory.create!(name: 'Global usage', info: "Global usage of functions", parent_category: usage_cat)
global_usage_cat_attr = {
  stat_category: global_usage_cat,
  stat_type: :proportion,
  event_filters: {}
}
Stat.create!(global_usage_cat_attr.merge({name: 'Functions usage', node: 'type', stat_type: :proportion}))
Stat.create!(global_usage_cat_attr.merge({name: 'Success rate', node: 'success', stat_type: :proportion}))
Stat.create!(global_usage_cat_attr.merge({name: 'Errno', node: 'errno', stat_type: :proportion}))

# Send family
send_family = [:send, :sendto, :sendmsg, :sendmmsg, :write, :writev, :sendfile]
send_flags = [:MSG_CONFIRM, :MSG_DONTROUTE, :MSG_DONTWAIT, :MSG_EOR, :MSG_MORE, :MSG_NOSIGNAL, :MSG_OOB]
send_family_cat = StatCategory.create!(name: 'Send-family', info: "About functions used for sending data over a socket (#{send_family.join(", ")})", parent_category: usage_cat)
send_family_cat_attr = {
  stat_category: send_family_cat,
  stat_type: :proportion,
  event_filters: {type: { '$in': send_family }}
}
Stat.create!(send_family_cat_attr.merge({name: 'Send-family usage', node: 'type', stat_type: :proportion}))
Stat.create!(send_family_cat_attr.merge({name: 'Send-family success-rate', node: 'success', stat_type: :proportion}))
Stat.create!(send_family_cat_attr.merge({name: 'Send-family buffer size', node: 'details.bytes', stat_type: :cdf}))
Stat.create!(send_family_cat_attr.merge({name: 'Send-family bytes sent', node: 'return_value', stat_type: :cdf}))
send_flags.each do |flag|
  Stat.create!(send_family_cat_attr.merge({name: "Sending flags #{flag}", node: "details.flags.#{flag}", stat_type: :proportion}))
end

# Recv family
recv_family = [:recv, :recvfrom, :recvmsg, :recvmmsg, :read, :readv]
recv_flags = [:MSG_CMSG_CLOEXEC, :MSG_DONTWAIT, :MSG_ERRQUEUE, :MSG_OOB, :MSG_PEEK, :MSG_TRUNC, :MSG_WAITALL]
recv_family_cat = StatCategory.create!(name: 'Recv-family', info: "About functions used for receiving data on a socket (#{recv_family.join(", ")})", parent_category: usage_cat)
recv_family_cat_attr = {
  stat_category: recv_family_cat,
  stat_type: :proportion,
  event_filters: {type: { '$in': recv_family }}
}
Stat.create!(recv_family_cat_attr.merge({name: 'Recv-family usage', node: 'type', stat_type: :proportion}))
Stat.create!(recv_family_cat_attr.merge({name: 'Recv-family success-rate', node: 'success', stat_type: :proportion}))
Stat.create!(recv_family_cat_attr.merge({name: 'Recv-family buffer size', node: 'details.bytes', stat_type: :cdf}))
Stat.create!(recv_family_cat_attr.merge({name: 'Recv-family bytes received', node: 'return_value', stat_type: :cdf}))
recv_flags.each do |flag|
  Stat.create!(recv_family_cat_attr.merge({name: "Receiving flags #{flag}", node: "details.flags.#{flag}", stat_type: :proportion}))
end

# Async family
async_families = [:select_family, :poll_family, :epoll_family]
async_functions = {
  select_family: [:select, :pselect],
  poll_family:   [:poll, :ppoll],
  epoll_family:  [:epoll_ctl, :epoll_wait, :epoll_pwait]
}
events = {
  select_family: [:READ, :WRITE, :EXCEPT],
  poll_family:   [:POLLIN, :POLLPRI, :POLLOUT, :POLLRDHUP, :POLLERR, :POLLHUP, :POLLNVAL],
  epoll_family:  [:EPOLLIN, :EPOLLOUT, :EPOLLRDHUP, :EPOLLPRI, :EPOLLERR, :EPOLLHUP, :EPOLLET, :EPOLLONESHOT, :EPOLLWAKEUP]
}
async_family = async_functions.values.flatten
async_family_cat = StatCategory.create!(name: 'Async I/O functions', info: "About functions used for async I/O (#{async_family.join(", ")})", parent_category: usage_cat)
async_family_cat_attr = {
  stat_category: async_family_cat,
  stat_type: :proportion,
}

def async_description(functions, ev_type, event)
  if ev_type == :requested_events
    "Proportion of #{functions} calls that request the event #{event}"
  else
    "Proportion of #{functions} calls for which the event #{event} is returned"
  end
end

async_families.each do |family|
  [:requested_events, :returned_events].each do |ev_type|
    events[family].each do |event|
      Stat.create!(async_family_cat_attr.merge({
        event_filters: {type: { '$in': async_functions[family] }},
        name: "#{family.to_s.humanize} #{ev_type.to_s.humanize.downcase}: #{event}",
        node: "details.#{ev_type}.#{event}",
        stat_type: :proportion,
        description: async_description(async_functions[family], ev_type, event)
      }))
    end
  end
end
