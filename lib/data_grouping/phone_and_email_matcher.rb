require "data_grouping/abstract_matcher"

module DataGrouping
  class PhoneAndEmailMatcher < AbstractMatcher
    PHONE_NUMBER_REGEX = /\d{3}.*\d{3}.*\d{4}\z/

    def normalize(value)
      if value&.strip&.match?(PHONE_NUMBER_REGEX)
        value.scan(/\d/).join
      else
        value&.downcase
      end
    end

    private

    def header_regex
      /(Email|Phone)/
    end
  end
end
