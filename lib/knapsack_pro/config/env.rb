module KnapsackPro
  module Config
    class Env
      LOG_LEVELS = {
        'fatal'  => ::Logger::FATAL,
        'error'  => ::Logger::ERROR,
        'warn'  => ::Logger::WARN,
        'info'  => ::Logger::INFO,
        'debug' => ::Logger::DEBUG,
      }

      class << self
        def ci_node_total
          (ENV['KNAPSACK_PRO_CI_NODE_TOTAL'] ||
            ci_env_for(:node_total) ||
            1).to_i
        end

        def ci_node_index
          (ENV['KNAPSACK_PRO_CI_NODE_INDEX'] ||
            ci_env_for(:node_index) ||
            0).to_i
        end

        def ci_node_build_id
          ENV['KNAPSACK_PRO_CI_NODE_BUILD_ID'] ||
            ci_env_for(:node_build_id) ||
            'missing-build-id'
        end

        def ci_node_retry_count
          (
            ENV['KNAPSACK_PRO_CI_NODE_RETRY_COUNT'] ||
            ci_env_for(:node_retry_count) ||
            0
          ).to_i
        end

        def commit_hash
          ENV['KNAPSACK_PRO_COMMIT_HASH'] ||
            ci_env_for(:commit_hash)
        end

        def branch
          ENV['KNAPSACK_PRO_BRANCH'] ||
            ci_env_for(:branch)
        end

        def project_dir
          ENV['KNAPSACK_PRO_PROJECT_DIR'] ||
            ci_env_for(:project_dir)
        end

        def test_file_pattern
          ENV['KNAPSACK_PRO_TEST_FILE_PATTERN']
        end

        def test_file_exclude_pattern
          ENV['KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN']
        end

        def test_dir
          ENV['KNAPSACK_PRO_TEST_DIR']
        end

        def repository_adapter
          ENV['KNAPSACK_PRO_REPOSITORY_ADAPTER']
        end

        def fixed_queue_split
          ENV.fetch('KNAPSACK_PRO_FIXED_QUEUE_SPLIT', false)
        end

        def fixed_queue_split?
          fixed_queue_split.to_s == 'true'
        end

        def cucumber_queue_prefix
          ENV.fetch('KNAPSACK_PRO_CUCUMBER_QUEUE_PREFIX', 'bundle exec')
        end

        def rspec_split_by_test_examples
          ENV.fetch('KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES', false)
        end

        def rspec_split_by_test_examples?
          rspec_split_by_test_examples.to_s == 'true'
        end

        def rspec_test_example_detector_prefix
          ENV.fetch('KNAPSACK_PRO_RSPEC_TEST_EXAMPLE_DETECTOR_PREFIX', 'bundle exec')
        end

        def test_suite_token
          env_name = 'KNAPSACK_PRO_TEST_SUITE_TOKEN'
          ENV[env_name] || raise("Missing environment variable #{env_name}. You should set environment variable like #{env_name}_RSPEC (note there is suffix _RSPEC at the end). knapsack_pro gem will set #{env_name} based on #{env_name}_RSPEC value. If you use other test runner than RSpec then use proper suffix.")
        end

        def test_suite_token_rspec
          return "123"
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC']
        end

        def test_suite_token_minitest
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST']
        end

        def test_suite_token_test_unit
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_TEST_UNIT']
        end

        def test_suite_token_cucumber
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER']
        end

        def test_suite_token_spinach
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH']
        end
        
        # TODO
        def redis_host
          ENV['KNAPSACK_PRO_REDIS_HOST']
          "localhost"
        end

        def redis_post
          ENV['KNAPSACK_PRO_REDIS_PORT'].to_i
          6379
        end

        def redis_db
          ENV['KNAPSACK_PRO_REDIS_DB'].to_i
          0
        end

        def mode
          mode = ENV['KNAPSACK_PRO_MODE']
          return :production if mode.nil?
          mode = mode.to_sym
          if [:development, :test, :production].include?(mode)
            mode
          else
            raise ArgumentError.new('Wrong mode name')
          end
        end

        def ci_env_for(env_name)
          value = nil
          ci_list = KnapsackPro::Config::CI.constants - [:Base]
          # load GitLab CI first to avoid edge case with order of loading envs for CI_NODE_INDEX
          ci_list.each do |ci_name|
            ci_class = Object.const_get("KnapsackPro::Config::CI::#{ci_name}")
            ci = ci_class.new
            value = ci.send(env_name)
            break unless value.nil?
          end
          value
        end

        def log_level
          LOG_LEVELS[ENV['KNAPSACK_PRO_LOG_LEVEL'].to_s.downcase] || ::Logger::DEBUG
        end

        def log_dir
          ENV['KNAPSACK_PRO_LOG_DIR']
        end

        private

        def required_env(env_name)
          ENV[env_name] || raise("Missing environment variable #{env_name}")
        end
      end
    end
  end
end
