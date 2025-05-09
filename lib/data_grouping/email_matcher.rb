require "data_grouping/abstract_matcher"

module DataGrouping
  class EmailMatcher < AbstractMatcher
    def normalize(value)
      value.downcase
    end

    private

    def header_regex
      /Email/
    end
  end
end
