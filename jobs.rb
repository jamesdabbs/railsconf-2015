require 'resque'
require 'sidekiq'

require 'pry'
require 'pry-stack_explorer'

class Base
  include Sidekiq::Worker

  # Set default queue (for Resque) by default
  def self.inherited other
    other.instance_variable_set :@queue, :default
  end

  # Allow Resque to use Sidekiq-style job definitions
  def self.perform *args
    new.perform *args
  end
end

#-----

class PryJob < Base
  def perform *args
    binding.pry
  end
end

class SlowJob < Base
  def perform
    puts "Sleeping ..."
    sleep
  end
end

class TickJob < Base
  def perform n=10
    n.to_i.downto 0 do |i|
      puts "#{Process.pid}: #{i}"
      sleep 1
    end
  end
end
