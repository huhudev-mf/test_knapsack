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
        password: KnapsackPro::Config::Env.redis_password,
      )
      puts "Redis Connected!"
    end

    def init_queue_redis(hash)
      @redis.lpush(hash, @all_test_files_to_run)
      @redis.lpush(hash, Array.new(KnapsackPro::Config::Env.ci_node_total) {|i| "finish" })
    end

    def get_from_redis(hash)
      return @redis.rpop(hash)
    end
  end
end
