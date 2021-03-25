module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        def self.run(args)
          require 'rspec/core'

          runner = new(KnapsackPro::Adapters::RSpecAdapter)
          cli_args = (args || '').split
          hash = Digest::MD5.hexdigest(
            KnapsackPro::Config::Env.commit_hash + 
            KnapsackPro::Config::Env.branch
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
            rspec_clear_examples
            exitstatus = exit_code if exit_code != 0
          end
          
          return {
            status: :next,
            exitstatus: exitstatus,
          }
        end

        def self.rspec_clear_examples
          if ::RSpec::ExampleGroups.respond_to?(:remove_all_constants)
            ::RSpec::ExampleGroups.remove_all_constants
          else
            ::RSpec::ExampleGroups.constants.each do |constant|
              ::RSpec::ExampleGroups.__send__(:remove_const, constant)
            end
          end
          ::RSpec.world.example_groups.clear
          ::RSpec.configuration.start_time = ::RSpec::Core::Time.now

          # Reset example group counts to ensure scoped example ids in metadata
          # have correct index (not increased by each subsequent run).
          # Solves this problem: https://github.com/rspec/rspec-core/issues/2721
          ::RSpec.world.instance_variable_set(:@example_group_counts_by_spec_file, Hash.new(0))

          # skip reset filters for old RSpec versions
          if ::RSpec.configuration.respond_to?(:reset_filters)
            ::RSpec.configuration.reset_filters
          end
        end
      end
    end
  end
end
