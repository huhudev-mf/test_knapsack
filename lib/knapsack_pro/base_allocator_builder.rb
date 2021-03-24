module KnapsackPro
  class BaseAllocatorBuilder
    TEST_RUNNER_MAP = {
      KnapsackPro::Adapters::RSpecAdapter => 'rspec',
    }

    def initialize(adapter_class)
      @adapter_class = adapter_class
    end

    def allocator
      raise NotImplementedError
    end

    def test_dir
      KnapsackPro::Config::Env.test_dir || TestFilePattern.test_dir(adapter_class)
    end

    private

    attr_reader :adapter_class

    def env
      KnapsackPro::Config::Env
    end

    def repository_adapter
      KnapsackPro::RepositoryAdapterInitiator.call
    end

    def test_file_pattern
      TestFilePattern.call(adapter_class)
    end

    def all_test_files_to_run
      KnapsackPro::TestFileFinder.call(test_file_pattern)
    end
  end
end
