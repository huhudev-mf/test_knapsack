module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        def self.run(args)
          require 'rspec/core'

          runner = new(KnapsackPro::Adapters::RSpecAdapter)
          cli_args = (args || '').split
          hash = Digest::MD5.hexdigest(
            KnapsackPro::Config::Env.project_name + 
            KnapsackPro::Config::Env.branch + 
            KnapsackPro::Config::Env.commit_hash
          )

          accumulator = {
            status: :next,
            exitstatus: 0,
          }

          if KnapsackPro::Config::Env.ci_node_index == 0
            runner.init_queue_redis(hash)
          end

          while accumulator[:status] == :next
            accumulator = run_tests(accumulator, runner, cli_args, hash)
          end

          Kernel.exit(accumulator[:exitstatus])
        end

        def self.run_tests(accumulator, runner, cli_args, hash)
          exitstatus = accumulator.fetch(:exitstatus)
          test_file_paths = runner.get_from_redis(hash)

          if test_file_paths.nil?
            sleep(1)
          else
            finish = false
            puts 
            if test_file_paths.include?("0")
              finish = true
              test_file_paths = test_file_paths.select {|t| t != "0" }
            end

            options = ::RSpec::Core::ConfigurationOptions.new(cli_args + test_file_paths)
            exit_code = ::RSpec::Core::Runner.new(options).run($stderr, $stdout)
            RSpec.clear_examples
            exitstatus = exit_code if exit_code != 0
          end
          
          if finish
            status = :completed
          else
            status = :next
          end

          return {
            status: status,
            exitstatus: exitstatus,
          }
        end
      end
    end
  end
end
