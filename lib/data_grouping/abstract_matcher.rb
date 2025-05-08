module DataGrouping
  class AbstractMatcher
    def initialize(headers)
      @checked_headers = headers.filter { |header| header.match?(header_regex) }
    end

    def match?(source_row, compared_row)
      @checked_headers.any? do |header|
        next if source_row[header].nil?

        @checked_headers.any? do |compared_header|
          next if compared_row[compared_header].nil?

          normalize(source_row[header]) == normalize(compared_row[compared_header])
        end
      end
    end

    private

    def header_regex
      raise NotImplementedError
    end

    def normalize(value)
      raise NotImplementedError
    end
  end
end
