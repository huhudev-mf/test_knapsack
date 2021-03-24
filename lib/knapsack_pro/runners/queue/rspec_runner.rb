module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        def self.run(args)
          require 'rspec/core'

          runner = new(KnapsackPro::Adapters::RSpecAdapter)

          cli_args = (args || '').split
          # if user didn't provide the format then use explicitly default progress formatter
          # in order to avoid KnapsackPro::Formatters::RSpecQueueSummaryFormatter being the only default formatter
          if !cli_args.any? { |arg| arg.start_with?('-f') || arg.start_with?('--format')}
            cli_args += ['--format', 'progress']
          end
  
          cli_args += [
            '--default-path', runner.test_dir,
          ]

          accumulator = {
            status: :next,
            runner: runner,
            can_initialize_queue: true,
            args: cli_args,
            exitstatus: 0,
          }
          while accumulator[:status] == :next
            accumulator = run_tests(accumulator)
          end

          Kernel.exit(accumulator[:exitstatus])
        end

        def self.run_tests(accumulator)
          runner = accumulator.fetch(:runner)
          can_initialize_queue = accumulator.fetch(:can_initialize_queue)
          args = accumulator.fetch(:args)
          exitstatus = accumulator.fetch(:exitstatus)

          test_file_path = runner.get_from_redis(can_initialize_queue)

          if test_file_path.nil?
            return {
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exitstatus,
            }
          elsif test_file_path == "finish"
            return {
              status: :completed,
              exitstatus: exitstatus,
            }
          else
            args.append(test_file_path)

            options = ::RSpec::Core::ConfigurationOptions.new(args)
            exit_code = ::RSpec::Core::Runner.new(options).run($stderr, $stdout)
            exitstatus = exit_code if exit_code != 0

            return {
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exitstatus,
            }
          end
        end
      end
    end
  end
end
