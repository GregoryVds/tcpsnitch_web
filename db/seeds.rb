######################
# NATURE OF SOCKETS #
####################
nature_of_sockets_cat = StatCategory.create!(name: 'Nature of sockets', description: 'About the sockets...', parent_category: nil)

# socket()
socket_cat = StatCategory.create!({
  name: 'socket()',
  description: 'Statistics about the socket() function usage.',
  parent_category: nature_of_sockets_cat
})
[:domain, :type, :protocol, :SOCK_CLOEXEC, :SOCK_NONBLOCK].each do |field|
  Stat.create!({
    event_filters: {type: :socket},
    stat_category: socket_cat,
    stat_type: :proportion,
    name: field,
    node: "details.sock_info.#{field}",
    description: "Breakdown of arguments used for the '#{field}' parameter of socket()."
  })
end

# getsockopt() & setsockopt()
sockopt_cat = StatCategory.create!({
  name: 'Socket options',
  description: 'Statistics about the usage of socket options.',
  parent_category: nature_of_sockets_cat
})
sockopt_cat_attr = {
  stat_category: sockopt_cat,
  stat_type: :proportion
}
[[:getsockopt, :setsockopt], [:getsockopt], [:setsockopt]].each do |group|
  [:level, :optname].each do |field|
    functions = group.map{|f|"#{f}()"}.join(" & ")
    Stat.create!(sockopt_cat_attr.merge({
      event_filters: {type: {'$in': group}},
      name: "#{functions} #{field}",
      node: "details.#{field}",
      description: "Breakdown of arguments used for the '#{field}' parameter of #{functions}."
    }))
  end
end

# fcntl()
fcntl_cat = StatCategory.create!({
  name: 'fcntl()',
  description: 'Statistics about the fcntl() function usage.',
  parent_category: nature_of_sockets_cat
})
fcntl_cat_attr = {
  stat_category: fcntl_cat,
  stat_type: :proportion
}
Stat.create!(fcntl_cat_attr.merge({
  event_filters: {type: 'fcntl'},
  name: 'fcntl() cmd',
  node: 'details.cmd',
  description: "Breakdown of arguments for the 'cmd' parameter of fnctl()"
}))
[:F_GETFD, :F_SET_FD].each do |cmd|
  Stat.create!(fcntl_cat_attr.merge({
    event_filters: {type: 'fcntl', 'details.cmd': cmd},
    name: "#{cmd}: O_CLOEXEC",
    node: 'details.O_CLOEXEC',
    description: "Proportion of fcntl() #{cmd} commands that set the flag O_CLOEXEC."
  }))
end

[:F_GETFL, :F_SETFL].each do |cmd|
  [:O_APPEND, :O_ASYNC, :O_DIRECT, :O_NOATIME, :O_NONBLOCK].each do |flag|
    Stat.create!(fcntl_cat_attr.merge({
      event_filters: {type: 'fcntl', 'details.cmd': cmd},
      name: "Command #{cmd}: #{flag}",
      node: "details.#{flag}",
      description: "Proportion of fcntl() #{cmd} commands that set the flag #{flag}."
    }))
  end
end

###################
# FUNCTIONS USAGE #
##################
usage_cat = StatCategory.create!(name: 'Functions usage', description: 'Statistics about the usage of various functions of the sockets API', parent_category: nil)

# Global usage
global_usage_cat = StatCategory.create!({
  name: 'Global usage',
  description: 'General statistic about functions usage.',
  parent_category: usage_cat
})
global_usage_cat_attr = {
  stat_category: global_usage_cat,
  stat_type: :proportion,
  event_filters: {}
}
Stat.create!(global_usage_cat_attr.merge({
  name: 'Functions usage',
  node: 'type',
  description: "Breakdown of functions usage."
}))
Stat.create!(global_usage_cat_attr.merge({
  name: 'Success rate',
  node: 'success',
  description: "Proportion of function calls that return successfully."
}))
Stat.create!(global_usage_cat_attr.merge({
  name: 'errno',
  node: 'errno',
  description: "Breakdown of errno error codes."
}))

# Send family
send_family = [:send, :sendto, :sendmsg, :sendmmsg, :write, :writev, :sendfile]
send_flags = [:MSG_CONFIRM, :MSG_DONTROUTE, :MSG_DONTWAIT, :MSG_EOR, :MSG_MORE, :MSG_NOSIGNAL, :MSG_OOB]
send_family_cat = StatCategory.create!({
  name: 'Send-like functions',
  description: "Statistic about the usage of functions designed to send data over a socket (#{send_family.join(", ")}).",
  parent_category: usage_cat
})
send_family_cat_attr = {
  stat_category: send_family_cat,
  stat_type: :proportion,
  event_filters: {type: { '$in': send_family }}
}
Stat.create!(send_family_cat_attr.merge({
  name: 'Send-like functions usage',
  node: 'type',
  stat_type: :proportion,
  description: "Breakdown of send-like functions usage."
}))
Stat.create!(send_family_cat_attr.merge({
  name: 'Send-like functions success-rate',
  node: 'success',
  stat_type: :proportion,
  description: "Success rate of send-like functions calls."
}))
Stat.create!(send_family_cat_attr.merge({
  name: 'Send-like functions buffer size',
  node: 'details.bytes',
  stat_type: :cdf,
  description: "Cumulative distribution function for the buffer size argument of send-like function calls."
}))
Stat.create!(send_family_cat_attr.merge({
  name: 'Send-like functions bytes sent',
  node: 'return_value',
  stat_type: :cdf,
  description: "Cumulative distribution function for the return value of send-like function calls. This corresponds to the number of bytes actually sent."
}))
send_flags.each do |flag|
  Stat.create!(send_family_cat_attr.merge({
    name: "Sending flags #{flag}",
    node: "details.flags.#{flag}",
    stat_type: :proportion,
    description: "Proportion of send-like functions calls that set the flag #{flag}."
  }))
end

# Recv family
recv_family = [:recv, :recvfrom, :recvmsg, :recvmmsg, :read, :readv]
recv_flags = [:MSG_CMSG_CLOEXEC, :MSG_DONTWAIT, :MSG_ERRQUEUE, :MSG_OOB, :MSG_PEEK, :MSG_TRUNC, :MSG_WAITALL]
recv_family_cat = StatCategory.create!({
  name: 'Recv-like functions',
  description: "Statistic about the usage of functions designed to receive data over a socket (#{recv_family.join(", ")}).",
  parent_category: usage_cat
})
recv_family_cat_attr = {
  stat_category: recv_family_cat,
  stat_type: :proportion,
  event_filters: {type: { '$in': recv_family }}
}
Stat.create!(recv_family_cat_attr.merge({
  name: 'Recv-like functions usage',
  node: 'type',
  stat_type: :proportion,
  description: "Breakdown of recv-like functions usage."
}))
Stat.create!(recv_family_cat_attr.merge({
  name: 'Recv-family success-rate',
  node: 'success',
  stat_type: :proportion,
  description: "Success rate of recv-like functions calls."
}))
Stat.create!(recv_family_cat_attr.merge({
  name: 'Recv-family buffer size',
  node: 'details.bytes',
  stat_type: :cdf,
  description: "Cumulative distribution function the buffer size argument of recv-like function calls."
}))
Stat.create!(recv_family_cat_attr.merge({
  name: 'Recv-family bytes received',
  node: 'return_value',
  stat_type: :cdf,
  description: "Cumulative distribution function for the return value of recv-like function calls. This corresponds to the number of bytes actually received."
}))
recv_flags.each do |flag|
  Stat.create!(recv_family_cat_attr.merge({
    name: "Receiving flags #{flag}",
    node: "details.flags.#{flag}",
    stat_type: :proportion,
    description: "Proportion of recv-like functions calls that set the flag #{flag}."
  }))
end

# Async family
async_families = [:select_like_functions, :poll_like_functions, :epoll_like_functions]
async_functions = {
  select_like_functions: [:select, :pselect],
  poll_like_functions:   [:poll, :ppoll],
  epoll_like_functions:  [:epoll_ctl, :epoll_wait, :epoll_pwait]
}
events = {
  select_like_functions: [:READ, :WRITE, :EXCEPT],
  poll_like_functions:   [:POLLIN, :POLLPRI, :POLLOUT, :POLLRDHUP, :POLLERR, :POLLHUP, :POLLNVAL],
  epoll_like_functions:  [:EPOLLIN, :EPOLLOUT, :EPOLLRDHUP, :EPOLLPRI, :EPOLLERR, :EPOLLHUP, :EPOLLET, :EPOLLONESHOT, :EPOLLWAKEUP]
}
async_family = async_functions.values.flatten
async_family_cat = StatCategory.create!({
  name: 'Async I/O functions',
  description: "Statistic about the usage of functions designed to perform async I/O (#{async_family.join(", ")}).",
  parent_category: usage_cat
})
async_family_cat_attr = {
  stat_category: async_family_cat,
  stat_type: :proportion,
}

def async_description(family, ev_type, event)
  if ev_type == :requested_events
    "Proportion of #{family} calls that request the event #{event}."
  else
    "Proportion of #{family} calls for which the event #{event} is returned."
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
        description: async_description(family.to_s.humanize, ev_type, event)
      }))
    end
  end
end
