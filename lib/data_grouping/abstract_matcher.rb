module DataGrouping
  class AbstractMatcher
    def initialize(headers)
      @checked_headers = headers.filter { |header| header.match?(header_regex) }
    end

    def match?(source_row, compared_row)
      scan_for_matches_on(row: source_row) do |source_value|
        scan_for_matches_on(row: compared_row) do |compared_value|
          normalize(source_value) == normalize(compared_value)
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

    def scan_for_matches_on(row:)
      @checked_headers.any? do |header|
        checked_value = row[header]
        next if checked_value.nil?

        yield checked_value
      end
    end
  end
end
