StatCategory.all.each(&:destroy)

def nodes_list(nodes, prefix)
  nodes.map{|node| "#{prefix}.#{node}"}.join(',')
end

def functions_list(functions)
  functions.map{|f|"#{f}()"}.join(', ')
end

dyn_filter_socket_ids = <<'EOF'
  analysable.socket_ids.map do |id|
    ["Socket ##{id}", {"socket_trace_id" => id}]
  end
EOF

############
# Overview #
############

send_family = [:send, :sendto, :sendmsg, :sendmmsg, :write, :writev, :sendfile]
recv_family = [:recv, :recvfrom, :recvmsg, :recvmmsg, :read, :readv]

overview_cat = StatCategory.create!({
  name: 'Overview'
})

overview_cat_attr = {
  stat_category: overview_cat,
  event_filters: {}
}

Stat.create!(overview_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: :type,
  name: 'Functions calls',
  description: "Breakdown of functions calls."
}))

Stat.create!(overview_cat_attr.merge({
  applies_to_app_trace: false,
  applies_to_process_trace: false,
  applies_to_socket_trace: false,
  stat_type: :count_distinct_node_val_by_group,
  node: :app,
  group_by: :type,
  name: 'Functions usage',
  description: 'Count of applications using each function.'
}))

Stat.create!(overview_cat_attr.merge({
  stat_type: :sum_node_val_for_filters,
  node: :return_value,
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

Stat.create!(overview_cat_attr.merge({
  applies_to_socket_trace: false,
  applies_to_process_trace: false,
  applies_to_app_trace: false,
  stat_type: :count_distinct_node_val,
  node: :app_trace_id,
  name: 'App traces count',
  description: 'App traces count.'
}))

Stat.create!(overview_cat_attr.merge({
  applies_to_socket_trace: false,
  applies_to_process_trace: false,
  stat_type: :count_distinct_node_val,
  node: :process_trace_id,
  name: 'Process traces count',
  description: 'Process traces count.'
}))

Stat.create!(overview_cat_attr.merge({
  applies_to_socket_trace: false,
  stat_type: :count_distinct_node_val,
  node: :socket_trace_id,
  name: 'Socket traces count',
  description: 'Socket traces count.'
}))

Stat.create!(overview_cat_attr.merge({
  stat_type: :simple_count,
  name: 'Events count',
  description: 'Events count.'
}))

##########
# Socket #
##########

socket_cat = StatCategory.create!({
  name: 'socket()',
  description: 'Statistics about the socket() function usage.'
})

socket_cat_attr = {
  event_filters: {type: :socket},
  stat_category: socket_cat
}

[:domain, :type, :protocol].each do |field|
  Stat.create!(socket_cat_attr.merge({
    stat_type: :count_by_group,
    group_by: "details.sock_info.#{field}",
    name: "Socket() #{field} args",
    description: "Breakdown of arguments used for the '#{field}' parameter of socket()."
  }))

  Stat.create!(socket_cat_attr.merge({
    applies_to_app_trace: false,
    applies_to_process_trace: false,
    applies_to_socket_trace: false,
    stat_type: :count_distinct_node_val_by_group,
    node: :app,
    group_by: "details.sock_info.#{field}",
    name: "Socket() #{field}s usage",
    description: "Count of applications using each socket() #{field}."
  }))
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
    name_prefix = (group.length == 1) ? functions : 'Sockopts'

    Stat.create!(sockopt_cat_attr.merge({
      event_filters: {type: {'$in': group}},
      group_by: "details.#{field}",
      name: "#{name_prefix} #{field} args",
      description: "Breakdown of arguments used for the '#{field}' parameter of #{functions}."
    }))

    Stat.create!(sockopt_cat_attr.merge({
      applies_to_app_trace: false,
      applies_to_process_trace: false,
      applies_to_socket_trace: false,
      event_filters: {type: {'$in': group}},
      stat_type: :count_distinct_node_val_by_group,
      node: :app,
      group_by: "details.#{field}",
      name: "#{name_prefix} #{field} usage",
      description: "Count of applications using each #{field} for #{functions}."
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
  group_by: 'details.cmd',
  name: 'fcntl() commands args',
  description: "Breakdown of arguments for the 'cmd' parameter of fcntl()."
}))

Stat.create!(fcntl_cat_attr.merge({
  applies_to_app_trace: false,
  applies_to_process_trace: false,
  applies_to_socket_trace: false,
  stat_type: :count_distinct_node_val_by_group,
  node: :app,
  group_by: 'details.cmd',
  name: 'fcntl() commands usage',
  description: 'Count of applications using each fcntl() command.'
}))

fcntl_fd_flags = [:O_CLOEXEC]
[:F_GETFD, :F_SETFD].each do |cmd|
  Stat.create!(fcntl_cat_attr.merge({
    stat_type: :pc_true_for_nodes,
    event_filters: {type: 'fcntl', 'details.cmd': cmd},
    node: nodes_list(fcntl_fd_flags, "details"),
    name: "Command #{cmd} flags",
    description: "Proportion of fcntl() #{cmd} commands that sets each flag."
  }))
end

fcntl_fl_flags = [:O_APPEND, :O_ASYNC, :O_DIRECT, :O_NOATIME, :O_NONBLOCK]
[:F_GETFL, :F_SETFL].each do |cmd|
  Stat.create!(fcntl_cat_attr.merge({
    stat_type: :pc_true_for_nodes,
    event_filters: {type: 'fcntl', 'details.cmd': cmd},
    node: nodes_list(fcntl_fl_flags, "details"),
    name: "Command #{cmd} flags",
    description: "Proportion of fcntl() #{cmd} commands that sets each flag."
  }))
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
  name: 'Send-like functions calls',
  description: 'Breakdown of send-like functions calls.'
}))

Stat.create!(send_family_cat_attr.merge({
  applies_to_app_trace: false,
  applies_to_process_trace: false,
  applies_to_socket_trace: false,
  stat_type: :count_distinct_node_val_by_group,
  node: :app,
  group_by: :type,
  name: 'Send-like functions usage',
  description: 'Count of applications using each function.'
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

Stat.create!(send_family_cat_attr.merge({
  stat_type: :node_val_cdf_for_filters,
  event_filters: {},
  custom: Hash[send_family.map{ |f| [f, {type: f}] }],
  node: 'details.bytes',
  name: "Send-like buffer size comparison",
  description: "Cumulative distribution function the buffer size argument of send-like function calls."
}))

Stat.create!(send_family_cat_attr.merge({
  applies_to_dataset: false,
  stat_type: :timeserie_sum_node_for_dyn_filters,
  event_filters: {
    type: { '$in': send_family },
    return_value: { '$ne': -1 }
  },
  custom: {to_eval: dyn_filter_socket_ids},
  node: 'return_value',
  name: "Bytes sent per socket",
  description: "Cumulative distribution function the buffer size argument of send-like function calls."
}))

Stat.create!(send_family_cat_attr.merge({
  event_filters: {type: :writev},
  stat_type: :node_val_cdf,
  node: 'details.iovec.iovec_count',
  name: "writev() iovec count",
  description: "Cumulative distribution function for the size of writev() iovec."
}))

Stat.create!(send_family_cat_attr.merge({
  event_filters: {type: :sendmsg},
  stat_type: :node_val_cdf,
  node: 'details.msghdr.iovec.iovec_count',
  name: "sendmsg() iovec count",
  description: "Cumulative distribution function for the size of sendmsg() iovec."
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
  name: 'Recv-like functions calls',
  description: "Breakdown of recv-like functions calls."
}))

Stat.create!(recv_family_cat_attr.merge({
  applies_to_app_trace: false,
  applies_to_process_trace: false,
  applies_to_socket_trace: false,
  stat_type: :count_distinct_node_val_by_group,
  node: :app,
  group_by: :type,
  name: 'Recv-like functions usage',
  description: 'Count of applications using each function.'
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

Stat.create!(recv_family_cat_attr.merge({
  stat_type: :node_val_cdf_for_filters,
  event_filters: {},
  custom: Hash[recv_family.map{ |f| [f, {type: f}] }],
  node: 'details.bytes',
  name: "Recv-like buffer size comparison",
  description: "Cumulative distribution function the buffer size argument of recv-like function calls."
}))

Stat.create!(recv_family_cat_attr.merge({
  applies_to_dataset: false,
  stat_type: :timeserie_sum_node_for_dyn_filters,
  event_filters: {
    type: { '$in': recv_family },
    return_value: { '$ne': -1 }
  },
  custom: {to_eval: dyn_filter_socket_ids},
  node: 'return_value',
  name: "Bytes received per socket",
  description: "Cumulative distribution function the buffer size argument of send-like function calls."
}))

Stat.create!(recv_family_cat_attr.merge({
  event_filters: {type: :readv},
  stat_type: :node_val_cdf,
  node: 'details.iovec.iovec_count',
  name: "readv() iovec count",
  description: "Cumulative distribution function for the size of readv() iovec."
}))

Stat.create!(recv_family_cat_attr.merge({
  event_filters: {type: :recvmsg},
  stat_type: :node_val_cdf,
  node: 'details.msghdr.iovec.iovec_count',
  name: "recvmsg() iovec count",
  description: "Cumulative distribution function for the size of recvmsg() iovec."
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

async_family_filter = {type: { '$in': async_functions.values_at(select, poll, epoll).flatten }}

Stat.create!({
    stat_category: async_family_cat,
    event_filters: async_family_filter,
    stat_type: :count_by_group,
    group_by: :type,
    name: 'Async I/O functions calls',
    description: 'Breakdown of async I/O functions calls.'
})

Stat.create!(overview_cat_attr.merge({
  stat_category: async_family_cat,
  event_filters: async_family_filter,
  applies_to_app_trace: false,
  applies_to_process_trace: false,
  applies_to_socket_trace: false,
  stat_type: :count_distinct_node_val_by_group,
  node: :app,
  group_by: :type,
  name: 'Async I/O Functions usage',
  description: 'Count of applications using each function.'
}))

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

ioctl_cat_attr = {
  stat_category: ioctl_cat,
  event_filters: {type: 'ioctl'},
}

Stat.create!(ioctl_cat_attr.merge({
  stat_type: :count_by_group,
  group_by: 'details.request',
  name: 'ioctl() requests args',
  description: "Breakdown of arguments used for the 'request' parameter of ioctl()."
}))

Stat.create!(ioctl_cat_attr.merge({
  applies_to_app_trace: false,
  applies_to_process_trace: false,
  applies_to_socket_trace: false,
  stat_type: :count_distinct_node_val_by_group,
  node: :app,
  group_by: 'details.request',
  name: 'ioctl() requests usage',
  description: 'Count of applications using each ioctl() request.'
}))

#################
# THREADS USAGE #
#################

threads_usage = StatCategory.create!({
  name: 'Threads usage',
  description: 'About threads usage...',
  applies_to_app_trace: false,
  applies_to_dataset: false
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

Stat.create!({
  stat_category: errno_cat,
  stat_type: :count_by_group,
  group_by: 'success',
  name: 'Success rate',
  description: "Proportion of function calls that return successfully."
})
Stat.create!({
  stat_category: errno_cat,
  stat_type: :count_by_group,
  group_by: 'errno',
  name: 'errno',
  description: "Breakdown of errno error codes for all functions."
})

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
