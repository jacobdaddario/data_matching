require "data_grouping/abstract_matcher"

module DataGrouping
  class PhoneMatcher < AbstractMatcher
    def normalize(value)
      value&.scan(/\d/)&.join
    end

    private

    def header_regex
      /Phone/
    end
  end
end
