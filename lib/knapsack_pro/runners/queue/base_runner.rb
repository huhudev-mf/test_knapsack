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

        def get_from_redis()
          allocator.get_from_redis()
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
