module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        def self.run(args)
          require 'rspec/core'

          runner = new(KnapsackPro::Adapters::RSpecAdapter)

          hash = Digest::MD5.hexdigest(
            KnapsackPro::Config::Env.commit_hash + 
            KnapsackPro::Config::Env.branch +
            KnapsackPro::Config::Env.node_build_id
          )
          cli_args = (args || '').split

          accumulator = {
            status: :next,
            runner: runner,
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
          test_file_path = runner.get_from_redis(hash)

          if test_file_path == "finish"
            return {
              status: :completed,
              exitstatus: exitstatus,
            }
          elsif test_file_path.nil?
            sleep(1)
          else
            options = ::RSpec::Core::ConfigurationOptions.new(cli_args + [test_file_path])
            exit_code = ::RSpec::Core::Runner.new(options).run($stderr, $stdout)
            RSpec.clear_examples
            exitstatus = exit_code if exit_code != 0
          end
          
          return {
            status: :next,
            exitstatus: exitstatus,
          }
        end
      end
    end
  end
end
