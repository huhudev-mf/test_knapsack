module KnapsackPro
  module Runners
    module Queue
      class BaseRunner
        def self.run(args)
          raise NotImplementedError
        end

        def self.run_tests(accumulator)
          raise NotImplementedError
        end

        def initialize(adapter_class)
          @allocator_builder = KnapsackPro::QueueAllocatorBuilder.new(adapter_class)
          @allocator = allocator_builder.allocator
        end

        def init_queue_redis(hash)
          allocator.init_queue_redis(hash)
        end

        def get_from_redis(hash)
          allocator.get_from_redis(hash)
        end

        def test_dir
          allocator_builder.test_dir
        end

        private

        attr_reader :allocator_builder,
          :allocator
      end
    end
  end
end
