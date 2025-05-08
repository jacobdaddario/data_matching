module DataGrouping
  class Index
    def initialize(table, matcher)
      @table = table
      @matcher = matcher
      @index = []
    end

    def build_index
      unsorted_index = []
      @table.each_with_index do |row, i|
        @matcher.checked_headers.each do |header|
          unsorted_index << { table_index: i, value: row[header] || "" }
        end
      end

      @index = unsorted_index.sort_by { |entry| entry[:value]  }
      self
    end

    def each_with_index(&block)
      @index.each_with_index(&block)
    end

    def length
      @index.length
    end
  end
end
