require 'logger'
require "redis"
require 'singleton'
require 'net/http'
require 'json'
require 'uri'
require 'open3'
require 'rake/testtask'
require 'digest'
require 'securerandom'
require_relative 'knapsack_pro/config/ci/base'
require_relative 'knapsack_pro/config/ci/circle'
require_relative 'knapsack_pro/config/ci/github_actions'
require_relative 'knapsack_pro/config/env'
require_relative 'knapsack_pro/repository_adapters/base_adapter'
require_relative 'knapsack_pro/repository_adapters/env_adapter'
require_relative 'knapsack_pro/repository_adapters/git_adapter'
require_relative 'knapsack_pro/repository_adapter_initiator'
require_relative 'knapsack_pro/test_file_cleaner'
require_relative 'knapsack_pro/test_file_presenter'
require_relative 'knapsack_pro/test_file_finder'
require_relative 'knapsack_pro/test_file_pattern'
require_relative 'knapsack_pro/task_loader'
require_relative 'knapsack_pro/adapters/rspec_adapter'
require_relative 'knapsack_pro/base_allocator_builder'
require_relative 'knapsack_pro/queue_allocator'
require_relative 'knapsack_pro/queue_allocator_builder'
require_relative 'knapsack_pro/runners/queue/base_runner'
require_relative 'knapsack_pro/runners/queue/rspec_runner'

require 'knapsack_pro/railtie' if defined?(Rails::Railtie)

module KnapsackPro
  class << self
    def root
      File.expand_path('../..', __FILE__)
    end

    def logger
      if KnapsackPro::Config::Env.log_dir
        default_logger = Logger.new("#{KnapsackPro::Config::Env.log_dir}/knapsack_pro_node_#{KnapsackPro::Config::Env.ci_node_index}.log")
        default_logger.level = KnapsackPro::Config::Env.log_level
        self.logger = default_logger
      end

      unless @logger
        default_logger = ::Logger.new(STDOUT)
        default_logger.level = KnapsackPro::Config::Env.log_level
        self.logger = default_logger
      end
      @logger
    end

    def logger=(logger)
      @logger = KnapsackPro::LoggerWrapper.new(logger)
    end

    def reset_logger!
      @logger = nil
    end

    def tracker
      KnapsackPro::Tracker.instance
    end

    def load_tasks
      task_loader = KnapsackPro::TaskLoader.new
      task_loader.load_tasks
    end
  end
end
