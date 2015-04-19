require 'redis-browser'
require 'resque/server'
require 'sidekiq/web'

map '/redis' do
  run RedisBrowser::Web
end

map '/resque' do
  run Resque::Server
end

map '/sidekiq' do
  run Sidekiq::Web
end
