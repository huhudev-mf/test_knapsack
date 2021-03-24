module KnapsackPro
  class QueueAllocatorBuilder < BaseAllocatorBuilder
    def allocator
      KnapsackPro::QueueAllocator.new(
        all_test_files_to_run: all_test_files_to_run,
        ci_node_total: env.ci_node_total,
        ci_node_index: env.ci_node_index,
        ci_node_build_id: env.ci_node_build_id,
        repository_adapter: repository_adapter,
      )
    end
  end
end
