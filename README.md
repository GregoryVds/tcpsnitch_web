# TCPSnitch Web

Web app live at www.tcpsnitch.org to centralize, visualize and analyze the traces gathered by [tcpsnitch](https://github.com/GregoryVds/tcpsnitch), a tracing tool designed to investigate the interactions between an application and the TCP/IP stack.

## Stack overview

- Ruby 2.3 (MongoDB driver does not support 2.4)
- Rails 5
- Puma
- Nginx
- MongoDB 3.4
- Postgresql
- Redis for storing background jobs
- Memcached for fragment caching

## Main gems

- Mongoid ORM framework for MongoDB.
- Sidekiq for background jobs processing.
- Carrierwave for file uploads.
- Chartkick to create charts.
- Activeadmin for administration interface.
- Whenever for managing Cron jobs.
- Capistrano for deployment.

## Sidekiq jobs

We currently use 4 priority queues to organize the background jobs:
- `default`, used for trace import jobs (archive import and socket trace import).
- `low`, `xlow`, and `xxlow` to compute statistics on app traces, process traces and socket traces respectively.

## Database

Currently, the `rake db:seed` task is always executed on deploy. It destroys all `Stats` and `StatCategories` before reseeding them. This is temporary.
