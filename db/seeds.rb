StatCategory.all.each(&:destroy)

def nodes_list(nodes, prefix)
  nodes.map{|node| "#{prefix}.#{node}"}.join(',')
end

def functions_list(functions)
  functions.map{|f|"#{f}()"}.join(', ')
end

#########
# About #
#########

send_family = [:send, :sendto, :sendmsg, :sendmmsg, :write, :writev, :sendfile]
recv_family = [:recv, :recvfrom, :recvmsg, :recvmmsg, :read, :readv]

about_cat = StatCategory.create!({name: 'about'})

about_cat_attr = {
  stat_category: about_cat,
  event_filters: {}
}

Stat.create!(about_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: 'type',
  name: 'Functions usage',
  description: "Breakdown of functions usage."
}))
Stat.create!(about_cat_attr.merge({
  stat_type: :sum_node_val_for_filters,
  node: 'return_value',
  custom: {
    'Bytes sent': {
      type: { '$in': send_family },
      return_value: { '$ne': -1 }
    },
    'Bytes received': {
      type: { '$in': recv_family },
      return_value: { '$ne': -1 }
    }
  },
  name: 'Bytes sent & received',
  description: 'Sum of bytes sent & received.'
}))


##########
# Socket #
##########

socket_cat = StatCategory.create!({
  name: 'socket()',
  description: 'Statistics about the socket() function usage.'
})

[:domain, :type, :protocol].each do |field|
  Stat.create!({
    stat_type: :count_by_group,
    event_filters: {type: :socket},
    stat_category: socket_cat,
    name: "Socket() #{field}",
    group_by: "details.sock_info.#{field}",
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
  stat_type: :count_by_group
}
[[:getsockopt, :setsockopt], [:getsockopt], [:setsockopt]].each do |group|
  [:level, :optname].each do |field|
    functions = functions_list(group)
    Stat.create!(sockopt_cat_attr.merge({
      event_filters: {type: {'$in': group}},
      name: "#{functions} #{field}",
      group_by: "details.#{field}",
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
  stat_type: :count_by_group,
  stat_category: fcntl_cat
}
Stat.create!(fcntl_cat_attr.merge({
  event_filters: {type: 'fcntl'},
  name: 'fcntl() commands',
  group_by: 'details.cmd',
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
  event_filters: {type: { '$in': send_family }}
}
Stat.create!(send_family_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: :type,
  name: 'Send-like functions usage',
  description: "Breakdown of send-like functions usage."
}))
Stat.create!(send_family_cat_attr.merge({
  stat_type: :sum_node_val_by_group,
  event_filters: {
    type: { '$in': send_family },
    return_value: { '$ne': -1 }
  },
  node: 'details.bytes',
  group_by: :type,
  name: 'Send-like sum of bytes sent',
  description: 'Sum of bytes sent per function type.'
}))
Stat.create!(send_family_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: :success,
  name: 'Send-like success-rate',
  description: "Success rate of send-like functions calls."
}))
Stat.create!(send_family_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: :errno,
  name: 'Send-like errnos',
  description: "Breakdown of errno error codes for send-like functions."
}))
Stat.create!(send_family_cat_attr.merge({
  stat_type: :pc_true_for_nodes,
  node: nodes_list(send_flags, "details.flags"),
  name: "Sending flags popularity",
  description: "Proportion of send-like functions calls that sets each flag."
}))
Stat.create!(send_family_cat_attr.merge({
  stat_type: :node_val_cdf,
  node: 'details.bytes',
  name: 'Send-like buffer size CDF',
  description: "Cumulative distribution function for the buffer size argument of send-like function calls."
}))
Stat.create!(send_family_cat_attr.merge({
  stat_type: :node_val_cdf,
  event_filters: {
    type: { '$in': send_family },
    return_value: { '$ne': -1 }
  },
  node: :return_value,
  name: 'Send-like bytes sent CDF',
  description: "Cumulative distribution function for the return value of send-like function calls. This corresponds to the number of bytes actually sent."
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
  event_filters: {type: { '$in': recv_family }}
}
Stat.create!(recv_family_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: :type,
  name: 'Recv-like functions usage',
  description: "Breakdown of recv-like functions usage."
}))
Stat.create!(recv_family_cat_attr.merge({
  stat_type: :sum_node_val_by_group,
  event_filters: {
    type: { '$in': recv_family },
    return_value: { '$ne': -1 }
  },
  node: 'details.bytes',
  group_by: :type,
  name: 'Recv-like sum of bytes received',
  description: 'Sum of bytes received per function type.'
}))
Stat.create!(recv_family_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: :success,
  name: 'Recv-like success-rate',
  description: "Success rate of recv-like functions calls."
}))
Stat.create!(recv_family_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: :errno,
  name: 'Recv-like errnos',
  description: "Breakdown of errno error codes for recv-like functions."
}))
Stat.create!(recv_family_cat_attr.merge({
  stat_type: :pc_true_for_nodes,
  node: nodes_list(recv_flags, "details.flags"),
  name: "Receiving flags popularity",
  description: "Proportion of recv-like functions calls that sets each flag."
}))
Stat.create!(recv_family_cat_attr.merge({
  stat_type: :node_val_cdf,
  node: 'details.bytes',
  name: 'Recv-like buffer size CDF',
  description: "Cumulative distribution function the buffer size argument of recv-like function calls."
}))
Stat.create!(recv_family_cat_attr.merge({
  stat_type: :node_val_cdf,
  event_filters: {
    type: { '$in': recv_family },
    return_value: { '$ne': -1 }
  },
  node: :return_value,
  name: 'Recv-like bytes received CDF',
  description: "Cumulative distribution function for the return value of recv-like function calls. This corresponds to the number of bytes actually received."
}))

#######################
# Async I/O functions #
#######################

select = 'select'
poll = 'poll'
epoll = 'epoll'
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

def async_description(functions, ev_type)
  if ev_type == :requested_events
    "Proportion of #{functions} calls that requests each event."
  else
    "Proportion of #{functions} calls that returns each event."
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
      name: "#{family} #{ev_type.to_s.humanize.downcase}",
      description: async_description(
        functions_list(async_functions[family]),
        ev_type
      )
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
  stat_type: :count_by_group,
  stat_category: ioctl_cat,
  event_filters: {type: 'ioctl'},
  group_by: 'details.request',
  name: 'ioctl() requests',
  description: "Breakdown of arguments used for the 'request' parameter of ioctl()."
})

#################
# THREADS USAGE #
#################

threads_usage = StatCategory.create!({
  name: 'Threads usage',
  description: 'About threads usage...',
  applies_to_app_trace: false,
})

Stat.create!({
  stat_category: threads_usage,
  event_filters: {
    type: { '$in': send_family },
    return_value: { '$ne': -1 }
  },
  stat_type: :sum_node_val_by_group,
  group_by: :thread_id,
  node: :return_value,
  name: 'Bytes sent per thread',
  description: 'Sum of bytes sent per thread.'
})

Stat.create!({
  stat_category: threads_usage,
  event_filters: {
    type: { '$in': recv_family },
    return_value: { '$ne': -1 }
  },
  stat_type: :sum_node_val_by_group,
  group_by: :thread_id,
  node: :return_value,
  name: 'Bytes received per thread',
  description: 'Sum of bytes received per thread.'
})

Stat.create!({
  stat_type: :count_by_group,
  stat_category: threads_usage,
  event_filters: {},
  group_by: :thread_id,
  name: 'Function calls per thread',
  description: 'Distribution of function calls among threads.'
})

Stat.create!({
  stat_type: :count_distinct_node_val_by_group,
  stat_category: threads_usage,
  event_filters: {},
  node: :socket_trace_id,
  group_by: :thread_id,
  name: 'Distinct sockets per thread',
  description: 'Count of distinct sockets accessed per thread.'
})

Stat.create!({
  stat_type: :count_distinct_node_val,
  stat_category: threads_usage,
  event_filters: {},
  node: :thread_id,
  name: 'Distinct threads count',
  description: 'Count of threads.'
})

##########
# Errnos #
##########

errno_cat = StatCategory.create!({
  name: 'Errnos',
  description: 'Breakdown of errno error codes.'
})

Stat.create!(about_cat_attr.merge({
  stat_category: errno_cat,
  stat_type: :count_by_group,
  group_by: 'success',
  name: 'Success rate',
  description: "Proportion of function calls that return successfully."
}))
Stat.create!(about_cat_attr.merge({
  stat_category: errno_cat,
  stat_type: :count_by_group,
  group_by: 'errno',
  name: 'errno',
  description: "Breakdown of errno error codes for all functions."
}))

[:bind, :connect, :shutdown, :listen, :accept, :accept4, :getsockopt,
 :setsockopt, :send, :recv, :sendto, :recvfrom, :sendmsg, :recvmsg, :sendmmsg,
 :recvmmsg, :getsockname, :getpeername, :sockatmark, :isfdtype, :write, :read,
 :close, :dup, :dup2, :dup3, :writev, :readv, :ioctl, :sendfile, :poll, :ppoll,
 :select, :pselect, :fcntl, :epoll_ctl, :epoll_wait, :epoll_pwait, :fdopen
].each do |function|
  Stat.create!({
    stat_type: :count_by_group,
    stat_category: errno_cat,
    event_filters: {type: function},
    group_by: :errno,
    name: "#{function}() errno",
    description: "Breakdown of errno error codes for #{function}."
  })
end
