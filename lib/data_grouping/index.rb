module DataGrouping
  class Index
    attr_reader :index

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

      # NOTE: For this algorithm to work, all rows that _can_ already have a match
      # _must_ have a match before identifying the `nil` values. Therefore, `nil`
      # values must be at the end of the index
      @index = unsorted_index.sort do |first_entry, second_entry|
        second_entry[:value] <=> first_entry[:value]
      end

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
