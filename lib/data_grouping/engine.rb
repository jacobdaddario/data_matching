require "csv"
require "securerandom"
require "debug"

module DataGrouping
  class Engine
    def initialize(filename:, matcher:)
      # NOTE: Typically we'd only let trusted users run a script like this, but better
      # safe than sorry. This line tries to prevent malicious inputs from the user.
      raise ArgumentError, "Only allowed to access data files" if filename.match?(/(\.\. | ~ | -)/)

      homogenized_filename = filename.delete_suffix(".csv")
      # We could chunk this for memory efficiency, but given that the largest file is only
      # ~ 2MB, it's an unneeded optimization right now. The smallest droplet on Digital Ocean
      # runs with 512 MiB, so unless the files becoming considerably larger we have no reason
      # to worry regardless of the execution environment.
      @file_contents = File.read(File.expand_path("../../data/#{homogenized_filename}.csv", __dir__))
      @table = prepend_id_column(CSV.parse(@file_contents, headers: true))

      @matcher = AVAILABLE_MATCHERS[matcher].new(@table.headers)

      raise ArgumentError, "Must supply a valid matcher. Valid matchers are: #{AVAILABLE_MATCHERS.keys.join(",")}" if @matcher.nil?
    end

    def run
      output = CSV.generate(write_headers: true, headers: @table.headers) do |output_csv|
        @table.each_with_index do |row, i|
          next_index = i + 1
          report_progress(next_index)

          # The row has already been tagged as duplicate if `id` isn't nil. No need
          # for further checking
          if !row["id"].nil?
            output_csv << row
            next
          end

          row["id"] = SecureRandom.uuid
          output_csv << row

          # If we're at the end of the table, no need check other rows
          break if i + 1 > @table.length

          # Tagging duplicate records
          @table[next_index..].each do |compared_row|
            compared_row["id"] = row["id"] if compared_row["id"].nil? && @matcher.match?(row, compared_row)
          end
        end
      end

      puts output
    end

    private

    # This feels crazy, but I couldn't figure out a better programmatic way to do
    # this.
    def prepend_id_column(table)
      new_headers = ["id"] + table.headers

      adjusted_csv = CSV.generate(write_headers: true, headers: new_headers) do |csv|
        table.each do |row|
          csv << [nil] + row.fields
        end
      end

      CSV.parse(adjusted_csv, headers: true)
    end

    def report_progress(index)
      puts "Processing row #{index}/#{@table.length}"
    end
  end
end
