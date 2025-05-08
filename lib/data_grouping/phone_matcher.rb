require "data_grouping/abstract_matcher"

module DataGrouping
  class PhoneMatcher < AbstractMatcher
    private

    def header_regex
      /Phone/
    end

    def normalize(value)
      value.scan(/\d/).join
    end
  end
end
