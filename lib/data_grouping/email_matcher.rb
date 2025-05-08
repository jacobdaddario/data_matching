require "data_grouping/abstract_matcher"

module DataGrouping
  class EmailMatcher < AbstractMatcher
    private

    def header_regex
      /Email/
    end

    def normalize(value)
      value.downcase
    end
  end
end
