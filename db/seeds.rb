# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

nature = StatCategory.create!(name: 'Nature of sockets', info: 'About the sockets...', parent_category: nil)

creation = StatCategory.create!(name: 'At creation', info: 'About the sockets...', parent_category: nature)
creation_stat = {
  apply_to_app_trace: true,
  apply_to_process_trace: true,
  apply_to_socket_trace: false,
  event_filters: {type: 'socket'},
  stat_category: creation,
  stat_type: :proportion
}
Stat.create!(creation_stat.merge({name: 'Domain', node: 'details.sock_info.domain'}))
Stat.create!(creation_stat.merge({name: 'Type', node: 'details.sock_info.types'}))
Stat.create!(creation_stat.merge({name: 'Protocol', node: 'details.sock_info.protocol'}))
Stat.create!(creation_stat.merge({name: 'Close on exec()', node: 'details.sock_info.SOCK_CLOEXEC'}))
Stat.create!(creation_stat.merge({name: 'Non-blocking', node: 'details.sock_info.SOCK_NONBLOCK'}))

sockopt = StatCategory.create!(name: 'Socket options', info: 'About the socket options usage', parent_category: nature)
sockopt_stat = {
  apply_to_app_trace: true,
  apply_to_process_trace: true,
  apply_to_socket_trace: true,
  stat_category: sockopt,
  stat_type: :proportion
}
Stat.create!(sockopt_stat.merge({event_filters: {type: {'$in': ['getsockopt','setsockopt']}}, name: 'Optname', node: 'details.optname'}))
Stat.create!(sockopt_stat.merge({event_filters: {type: {'$in': ['getsockopt','setsockopt']}}, name: 'Level', node: 'details.level'}))
Stat.create!(sockopt_stat.merge({event_filters: {type: 'getsockopt'}, name: 'Getsockopt optname', node: 'details.optname'}))
Stat.create!(sockopt_stat.merge({event_filters: {type: 'getsockopt'}, name: 'Getsockopt level', node: 'details.level'}))
Stat.create!(sockopt_stat.merge({event_filters: {type: 'setsockopt'}, name: 'Setsockopt optname', node: 'details.optname'}))
Stat.create!(sockopt_stat.merge({event_filters: {type: 'setsockopt'}, name: 'Setsockopt level', node: 'details.level'}))


usage = StatCategory.create!(name: 'Functions usage', info: 'About the usage of functions...', parent_category: nil)
send = StatCategory.create!(name: 'Send family', info: 'About the sockets...', parent_category: usage)
send_stat = {
  apply_to_app_trace: true,
  apply_to_process_trace: true,
  apply_to_socket_trace: true,
  stat_category: send,
}
Stat.create!(send_stat.merge({event_filters: {type: { '$in': ['recv', 'recvfrom', 'read'] }}, name: 'Receive family usage', node: 'type', stat_type: :proportion}))
Stat.create!(send_stat.merge({event_filters: {type: { '$in': ['recv', 'recvfrom', 'read'] }}, name: 'Receive family bytes', node: 'details.bytes', stat_type: :cdf}))

recv = StatCategory.create!(name: 'Recv family', info: 'About the sockets...', parent_category: usage)
recv_stat = {
  apply_to_app_trace: true,
  apply_to_process_trace: true,
  apply_to_socket_trace: true,
  stat_category: recv,
}
Stat.create!(recv_stat.merge({event_filters: {type: { '$in': ['send', 'sendto', 'write'] }}, name: 'Send family usage', node: 'type', stat_type: :proportion}))
Stat.create!(recv_stat.merge({event_filters: {type: { '$in': ['send', 'sendto', 'write'] }}, name: 'Send family bytes', node: 'details.bytes', stat_type: :cdf}))
