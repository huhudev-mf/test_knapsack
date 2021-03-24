module KnapsackPro
  class QueueAllocator
    def initialize(args)
      @all_test_files_to_run = args.fetch(:all_test_files_to_run)
      @ci_node_total = args.fetch(:ci_node_total)
      @ci_node_index = args.fetch(:ci_node_index)
      @ci_node_build_id = args.fetch(:ci_node_build_id)
      @repository_adapter = args.fetch(:repository_adapter)

      @redis = Redis.new(
        host: KnapsackPro::Config::Env.redis_host, 
        port: KnapsackPro::Config::Env.redis_post,
        db: KnapsackPro::Config::Env.redis_db,
      )
    end

    def get_from_redis(is_init)
      hash = Digest::MD5.hexdigest(KnapsackPro::Config::Env.commit_hash + KnapsackPro::Config::Env.branch)
      if is_init        
        if KnapsackPro::Config::Env.ci_node_index == 0
          put_redis(hash)
          put_finish_redis(hash, KnapsackPro::Config::Env.ci_node_total)
        end
      end

      test_file_path = get_redis(hash)
      return test_file_path
    end

    def put_redis(hash)
      @all_test_files_to_run.each do |test|
        @redis.rpush(hash, test['path'])
      end
    end

    def get_redis(hash)
      @redis.lpop(hash)
    end

    def put_finish_redis(hash, num)
      num.times do |i|
        @redis.rpush(hash, "finish")
      end
    end
  end
end
