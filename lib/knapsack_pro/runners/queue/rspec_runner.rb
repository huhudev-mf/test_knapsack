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
            all_test_file_paths: [],
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
          all_test_file_paths = accumulator.fetch(:all_test_file_paths)

          test_file_paths = runner.get_from_redis()

          if test_file_paths.empty?
            unless all_test_file_paths.empty?

              log_rspec_command(args, all_test_file_paths, :end_of_queue)
            end

            return {
              status: :completed,
              exitstatus: exitstatus,
            }
          else
            all_test_file_paths += test_file_paths
            cli_args = args + test_file_paths

            log_rspec_command(args, test_file_paths, :subset_queue)

            options = ::RSpec::Core::ConfigurationOptions.new(cli_args)
            exit_code = ::RSpec::Core::Runner.new(options).run($stderr, $stdout)
            exitstatus = exit_code if exit_code != 0

            KnapsackPro::Report.save_subset_queue_to_file

            return {
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exitstatus,
              all_test_file_paths: all_test_file_paths,
            }
          end
        end

        private

        def self.log_rspec_command(cli_args, test_file_paths, type)
          case type
          when :subset_queue
            KnapsackPro.logger.info("To retry in development the subset of tests fetched from API queue please run below command on your machine. If you use --order random then remember to add proper --seed 123 that you will find at the end of rspec command.")
          when :end_of_queue
            KnapsackPro.logger.info("To retry in development the tests for this CI node please run below command on your machine. It will run all tests in a single run. If you need to reproduce a particular subset of tests fetched from API queue then above after each request to Knapsack Pro API you will find example rspec command.")
          end

          stringify_cli_args = cli_args.join(' ')
          stringify_cli_args.slice!("--format #{KnapsackPro::Formatters::RSpecQueueSummaryFormatter}")

          KnapsackPro.logger.info(
            "bundle exec rspec #{stringify_cli_args} " +
            KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)
          )
        end
      end
    end
  end
end
