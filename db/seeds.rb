# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

nature    = StatCategory.create!(name: 'Nature of sockets', info: 'About the sockets...', parent_category: nil)
creation  = StatCategory.create!(name: 'At creation', info: 'About the sockets...', parent_category: nature)
sockopts  = StatCategory.create!(name: 'Sockopts', info: 'About the sockets...', parent_category: nature)
fcntl     = StatCategory.create!(name: 'Fnctl', info: 'About the sockets...', parent_category: nature)

usage     = StatCategory.create!(name: 'Functions usage', info: 'About the usage of functions...', parent_category: nil)
recv      = StatCategory.create!(name: 'Recv family', info: 'About the usage of functions...', parent_category: usage)
send      = StatCategory.create!(name: 'Send family', info: 'About the usage of functions...', parent_category: usage)

Stat.create!( apply_to_app_trace: true,
              apply_to_process_trace: true,
              apply_to_socket_trace: false,
              event_filters: {type: 'socket'},
              name: 'Domains',
              node: 'details.domain',
              stat_category: creation,
              stat_type: :proportion)

Stat.create!( apply_to_app_trace: true,
              apply_to_process_trace: true,
              apply_to_socket_trace: false,
              event_filters: {type: 'socket'},
              name: 'Types',
              node: 'details.types',
              stat_category: creation,
              stat_type: :proportion)

Stat.create!( apply_to_app_trace: true,
              apply_to_process_trace: true,
              apply_to_socket_trace: true,
              event_filters: {type: 'getsockopt'},
              name: 'Getsockopt optnames',
              node: 'details.optname',
              stat_category: sockopts,
              stat_type: :proportion)

Stat.create!( apply_to_app_trace: true,
              apply_to_process_trace: true,
              apply_to_socket_trace: true,
              event_filters: {type: 'setsockopt'},
              name: 'Setsockopt optnames',
              node: 'details.optname',
              stat_category: sockopts,
              stat_type: :proportion)

Stat.create!( apply_to_app_trace: true,
              apply_to_process_trace: true,
              apply_to_socket_trace: true,
              event_filters: {type: { '$in': ['recv', 'read'] }},
              name: 'Recv-family usage',
              node: 'type',
              stat_category: recv,
              stat_type: :proportion)

Stat.create!( apply_to_app_trace: true,
              apply_to_process_trace: true,
              apply_to_socket_trace: true,
              event_filters: {type: { '$in': ['recv', 'read'] }},
              name: 'Send-family usage',
              node: 'type',
              stat_category: recv,
              stat_type: :cdf)
