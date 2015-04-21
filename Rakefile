require 'bundler'
Bundler.setup

require 'rake'
require 'resque/tasks'
require 'resque/pool/tasks'


namespace :resque do
  task :setup do
    ENV['QUEUE'] = '*'
    # See http://hone.herokuapp.com/resque/2012/08/21/resque-signals.html
    ENV['TERM_CHILD'] = '1'

    require_relative './jobs'
  end
end

namespace :sidekiq do
  desc "Start sidekiq workers"
  task :work do
    require "sidekiq/cli"

    workers = ENV["WORKERS"] || "1"
    puts "Starting sidekiq with #{workers} workers"

    # Cheating a little by hooking into the CLI
    # This is what `bundle exec sidekiq` does
    cli = Sidekiq::CLI.instance
    cli.parse ["-r", "./jobs.rb", "-c", workers]
    cli.run
  end
end
