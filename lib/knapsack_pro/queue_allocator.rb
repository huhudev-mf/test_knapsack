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

    def init_queue_redis(hash)
      @all_test_files_to_run.each do |test|
        @redis.rpush(hash, test['path'])
      end
      KnapsackPro::Config::Env.ci_node_total.times do |i|
        @redis.rpush(hash, "finish")
      end
    end

    def get_from_redis(hash)
      return @redis.lpop(hash)
    end
  end
end
