#!/usr/bin/env ruby

require "bundler"
Bundler.setup

require "thor"
require_relative "./jobs"

class Q < Thor
  desc "resque", "Add a job to Resque"
  method_option :count, aliases: "-c", default: 1
  def resque job, *args
    enqueue "Resque", job do |klass|
      Resque.enqueue klass, *args
    end
  end

  desc "sidekiq", "Add a job to Sidekiq"
  method_option :count, aliases: "-c", default: 1
  def sidekiq job, *args
    enqueue "Sidekiq", job do |klass|
      klass.perform_async *args
    end
  end

private

  def enqueue label, job, *args
    klass = Object.const_get job
    count = options[:count] || 1
    count.to_i.times { yield(klass, *args) }
    puts "[#{label}] #{klass}x#{count}"
  end
end

Q.start
