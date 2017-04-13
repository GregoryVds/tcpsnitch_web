StatCategory.all.each(&:destroy)

def nodes_list(nodes, prefix)
  nodes.map{|node| "#{prefix}.#{node}"}.join(',')
end

##########
# Socket #
##########

socket_cat = StatCategory.create!({
  name: 'socket()',
  description: 'Statistics about the socket() function usage.'
})

[:domain, :type, :protocol].each do |field|
  Stat.create!({
    event_filters: {type: :socket},
    stat_category: socket_cat,
    stat_type: :proportion,
    name: field,
    node: "details.sock_info.#{field}",
    description: "Breakdown of arguments used for the '#{field}' parameter of socket()."
  })
end

socket_flags = [:SOCK_CLOEXEC, :SOCK_NONBLOCK]
Stat.create!({
  event_filters: {type: :socket},
  stat_category: socket_cat,
  stat_type: :pc_true_for_nodes,
  node: nodes_list(socket_flags, "details.sock_info"),
  name: "Socket() flags popularity",
  description: "Proportion of socket() calls that set each flag."
})

##################
# Socket options #
##################

sockopt_cat = StatCategory.create!({
  name: 'Socket options',
  description: 'Statistics about the usage of socket options.'
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

#########
# Fcntl #
#########

fcntl_cat = StatCategory.create!({
  name: 'fcntl()',
  description: 'Statistics about the fcntl() function usage.'
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

fcntl_fd_flags = [:O_CLOEXEC]
[:F_GETFD, :F_SETFD].each do |cmd|
  Stat.create!(fcntl_cat_attr.merge({
    stat_category: fcntl_cat,
    stat_type: :pc_true_for_nodes,
    event_filters: {type: 'fcntl', 'details.cmd': cmd},
    node: nodes_list(fcntl_fd_flags, "details"),
    name: "Command #{cmd} flags",
    description: "Proportion of fcntl() #{cmd} commands that sets each flag."
  }))
end

fcntl_fl_flags = [:O_APPEND, :O_ASYNC, :O_DIRECT, :O_NOATIME, :O_NONBLOCK]
[:F_GETFL, :F_SETFL].each do |cmd|
  Stat.create!({
    stat_category: fcntl_cat,
    stat_type: :pc_true_for_nodes,
    event_filters: {type: 'fcntl', 'details.cmd': cmd},
    node: nodes_list(fcntl_fl_flags, "details"),
    name: "Command #{cmd} flags",
    description: "Proportion of fcntl() #{cmd} commands that sets each flag."
  })
end

###################
# Functions usage #
###################

send_family = [:send, :sendto, :sendmsg, :sendmmsg, :write, :writev, :sendfile]
recv_family = [:recv, :recvfrom, :recvmsg, :recvmmsg, :read, :readv]

functions_usage_cat = StatCategory.create!({
  name: 'Functions usage',
  description: 'General statistic about functions usage.'
})

functions_usage_cat_attr = {
  stat_category: functions_usage_cat,
  stat_type: :proportion,
  event_filters: {}
}

Stat.create!(functions_usage_cat_attr.merge({
  name: 'Functions usage',
  node: 'type',
  description: "Breakdown of functions usage."
}))
Stat.create!(functions_usage_cat_attr.merge({
  stat_type: :sum_by_group,
  event_filters: {
    type: { '$in': send_family+recv_family },
    return_value: { '$ne': -1 }
  },
  name: 'Bytes sent/received',
  node: 'return_value',
  group_by: 'type',
  description: 'Sum of bytes sent or received per function type.'
}))

Stat.create!(functions_usage_cat_attr.merge({
  name: 'Success rate',
  node: 'success',
  description: "Proportion of function calls that return successfully."
}))
Stat.create!(functions_usage_cat_attr.merge({
  name: 'errno',
  node: 'errno',
  description: "Breakdown of errno error codes."
}))

#######################
# Send-like functions #
#######################

send_flags = [:MSG_CONFIRM, :MSG_DONTROUTE, :MSG_DONTWAIT, :MSG_EOR, :MSG_MORE, :MSG_NOSIGNAL, :MSG_OOB]
send_family_cat = StatCategory.create!({
  name: 'Send-like functions',
  description: "Statistic about the usage of functions designed to send data over a socket (#{send_family.join(", ")})."
})
send_family_cat_attr = {
  stat_category: send_family_cat,
  stat_type: :proportion,
  event_filters: {type: { '$in': send_family }}
}
Stat.create!(send_family_cat_attr.merge({
  name: 'Send-like functions usage',
  node: :type,
  stat_type: :proportion,
  description: "Breakdown of send-like functions usage."
}))
Stat.create!(send_family_cat_attr.merge({
  stat_type: :sum_by_group,
  event_filters: {
    type: { '$in': send_family },
    return_value: { '$ne': -1 }
  },
  name: 'Send-like functions sum of bytes sent',
  node: 'details.bytes',
  group_by: :type,
  description: 'Sum of bytes sent per function type.'
}))
Stat.create!(send_family_cat_attr.merge({
  name: 'Send-like functions success-rate',
  node: :success,
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
  event_filters: {
    type: { '$in': send_family },
    return_value: { '$ne': -1 }
  },
  name: 'Send-like functions bytes sent',
  node: :return_value,
  stat_type: :cdf,
  description: "Cumulative distribution function for the return value of send-like function calls. This corresponds to the number of bytes actually sent."
}))
Stat.create!(send_family_cat_attr.merge({
  name: "Sending flags popularity",
  node: nodes_list(send_flags, "details.flags"),
  stat_type: :pc_true_for_nodes,
  description: "Proportion of send-like functions calls that sets each flag."
}))

#######################
# Recv-like functions #
#######################

recv_flags = [:MSG_CMSG_CLOEXEC, :MSG_DONTWAIT, :MSG_ERRQUEUE, :MSG_OOB, :MSG_PEEK, :MSG_TRUNC, :MSG_WAITALL]
recv_family_cat = StatCategory.create!({
  name: 'Recv-like functions',
  description: "Statistic about the usage of functions designed to receive data over a socket (#{recv_family.join(", ")})."
})
recv_family_cat_attr = {
  stat_category: recv_family_cat,
  stat_type: :proportion,
  event_filters: {type: { '$in': recv_family }}
}
Stat.create!(recv_family_cat_attr.merge({
  name: 'Recv-like functions usage',
  node: :type,
  stat_type: :proportion,
  description: "Breakdown of recv-like functions usage."
}))
Stat.create!(recv_family_cat_attr.merge({
  stat_type: :sum_by_group,
  event_filters: {
    type: { '$in': recv_family },
    return_value: { '$ne': -1 }
  },
  name: 'Recv-like functions sum of bytes received',
  node: 'details.bytes',
  group_by: :type,
  description: 'Sum of bytes received per function type.'
}))
Stat.create!(recv_family_cat_attr.merge({
  name: 'Recv-family success-rate',
  node: :success,
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
  event_filters: {
    type: { '$in': recv_family },
    return_value: { '$ne': -1 }
  },
  name: 'Recv-family bytes received',
  node: :return_value,
  stat_type: :cdf,
  description: "Cumulative distribution function for the return value of recv-like function calls. This corresponds to the number of bytes actually received."
}))
Stat.create!(recv_family_cat_attr.merge({
  name: "Receiving flags popularity",
  node: nodes_list(recv_flags, "details.flags"),
  stat_type: :pc_true_for_nodes,
  description: "Proportion of recv-like functions calls that sets each flag."
}))

#######################
# Async I/O functions #
#######################

select = '(p)select'
poll = '(p)poll'
epoll = 'epoll_(p)wait & epoll_ctl'
async_families = [select, poll, epoll]
async_functions = {
  select  => [:select, :pselect],
  poll    => [:poll, :ppoll],
  epoll   => [:epoll_ctl, :epoll_wait, :epoll_pwait]
}
events = {
  select  => [:READ, :WRITE, :EXCEPT],
  poll    => [:POLLIN, :POLLPRI, :POLLOUT, :POLLRDHUP, :POLLERR, :POLLHUP, :POLLNVAL],
  epoll   => [:EPOLLIN, :EPOLLOUT, :EPOLLRDHUP, :EPOLLPRI, :EPOLLERR, :EPOLLHUP, :EPOLLET, :EPOLLONESHOT, :EPOLLWAKEUP]
}
async_family = async_functions.values.flatten
async_family_cat = StatCategory.create!({
  name: 'Async I/O functions',
  description: "Statistic about the usage of functions designed to perform async I/O (#{async_family.join(", ")})."
})

def async_description(family, ev_type)
  if ev_type == :requested_events
    "Proportion of #{family} calls that ask for a type of event."
  else
    "Proportion of #{family} calls for which a type of event is returned."
  end
end
# TODO function calls popularity

async_families.each do |family|
  [:requested_events, :returned_events].each do |ev_type|
    Stat.create!({
      stat_category: async_family_cat,
      stat_type: :pc_true_for_nodes,
      event_filters: {type: { '$in': async_functions[family] }},
      node: nodes_list(events[family], "details.#{ev_type}"),
      name: "#{family} #{ev_type.to_s.humanize.downcase} popularity",
      description: async_description(family, ev_type)
    })
  end
end

#########
# ioctl #
#########

ioctl_cat = StatCategory.create!({
  name: 'ioctl()',
  description: "Statistic about the usage of the ioctl() function"
})
Stat.create!({
  stat_category: ioctl_cat,
  event_filters: {type: 'ioctl'},
  name: 'ioctl() requests',
  stat_type: :proportion,
  node: 'details.request',
  description: "Breakdown of arguments used for the 'request' parameter of ioctl()."
})

#################
# THREADS USAGE #
#################

threads_usage = StatCategory.create!({
  name: 'Threads usage',
  description: 'About threads usage...',
  applies_to_app_trace: false,
  applies_to_process_trace: false
})


