module KnapsackPro
  module Adapters
    class RSpecAdapter
      TEST_DIR_PATTERN = 'spec/**/*_spec.rb'

      def self.test_path(example_group)
        if defined?(::Turnip) && ::Turnip::VERSION.to_i < 2
          unless example_group[:turnip]
            until example_group[:parent_example_group].nil?
              example_group = example_group[:parent_example_group]
            end
          end
        else
          until example_group[:parent_example_group].nil?
            example_group = example_group[:parent_example_group]
          end
        end

        example_group[:file_path]
      end
    end
  end
end
