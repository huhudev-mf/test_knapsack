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
          (ENV['CI_NODE_TOTAL'] ||
            ci_env_for(:node_total) ||
            1).to_i
        end

        def ci_node_index
          (ENV['CI_NODE_INDEX'] ||
            ci_env_for(:node_index) ||
            0).to_i
        end

        def ci_node_build_id
          ENV['CI_NODE_BUILD_ID'] ||
            ci_env_for(:node_build_id) ||
            'missing-build-id'
        end

        def ci_node_retry_count
          (
            ENV['CI_NODE_RETRY_COUNT'] ||
            ci_env_for(:node_retry_count) ||
            0
          ).to_i
        end

        def commit_hash
          ENV['COMMIT_HASH'] ||
            ci_env_for(:commit_hash)
        end

        def branch
          ENV['BRANCH'] ||
            ci_env_for(:branch)
        end

        def project_dir
          ENV['PROJECT_DIR'] ||
            ci_env_for(:project_dir)
        end

        def test_file_pattern
          ENV['TEST_FILE_PATTERN']
        end

        def test_file_exclude_pattern
          ENV['TEST_FILE_EXCLUDE_PATTERN']
        end

        def test_dir
          ENV['TEST_DIR']
        end

        def repository_adapter
          ENV['REPOSITORY_ADAPTER']
        end

        def redis_host
          ENV['REDIS_HOST']
          "localhost"
        end

        def redis_post
          ENV['REDIS_PORT'].to_i
          6379
        end

        def redis_db
          ENV['REDIS_DB'].to_i
          0
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
          LOG_LEVELS[ENV['LOG_LEVEL'].to_s.downcase] || ::Logger::DEBUG
        end

        def log_dir
          ENV['LOG_DIR']
        end
      end
    end
  end
end
