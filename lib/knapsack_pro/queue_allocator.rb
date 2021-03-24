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

    def get_from_redis()
      puts @all_test_files_to_run
      # hash = Digest::MD5.hexdigest(@repository_adapter.commit_hash + @repository_adapter.branch)
      # TODO
      puts @redis.get("test")
      []
    end
  end
end
