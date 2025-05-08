module DataGrouping
  class AbstractMatcher
    attr_reader :checked_headers

    def initialize(headers)
      @checked_headers = headers.filter { |header| header.match?(header_regex) }
    end

    def match?(source_value, compared_value)
      return false if is_blank?(source_value) || is_blank?(compared_value)

      normalize(source_value) == normalize(compared_value)
    end

    private

    def is_blank?(value)
      value.nil? || value.strip == ""
    end

    def header_regex
      raise NotImplementedError
    end

    def normalize(value)
      raise NotImplementedError
    end
  end
end
