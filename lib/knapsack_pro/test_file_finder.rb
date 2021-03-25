module KnapsackPro
  class TestFileFinder
    def self.call(test_file_pattern, test_file_list_enabled: true)
      new(test_file_pattern, test_file_list_enabled).call
    end

    def initialize(test_file_pattern, test_file_list_enabled)
      @test_file_pattern = test_file_pattern
      @test_file_list_enabled = test_file_list_enabled
    end

    def call
      test_file_hashes = []
      test_files.each do |test_file_path|
        test_file_hashes << TestFileCleaner.clean(test_file_path)
      end
      test_file_hashes
    end

    private

    attr_reader :test_file_pattern, :test_file_list_enabled

    def test_files
      stdout, stdeerr, status = Open3.capture3('bundle exec rspec --format j --dry-run ' + @test_file_pattern + ' | grep -ohE \'\{.+\}\' | python -c "import sys, json; list([sys.stdout.write(x[\'id\'][2:] + \'\n\') for x in json.load(sys.stdin)[\'examples\']])"')
      test_file_paths = stdout.split("\n")

      excluded_test_file_paths =
        if KnapsackPro::Config::Env.test_file_exclude_pattern
          Dir.glob(KnapsackPro::Config::Env.test_file_exclude_pattern).uniq
        else
          []
        end

      (test_file_paths - excluded_test_file_paths).sort
    end
  end
end
