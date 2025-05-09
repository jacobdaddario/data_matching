require "csv"
require "securerandom"
require "data_grouping/index"

module DataGrouping
  class Engine
    def initialize(filename:, matcher:)
      # NOTE: Typically we'd only let trusted users run a script like this, but better
      # safe than sorry. This line tries to prevent malicious inputs from the user.
      raise ArgumentError, "Only allowed to access data files" if filename.match?(/(\.\. | ~ | -)/)

      @filename = filename.delete_suffix(".csv")
      # We could chunk this for memory efficiency, but given that the largest file is only
      # ~ 2MB, it's an unneeded optimization right now. The smallest droplet on Digital Ocean
      # runs with 512 MiB, so unless the files becoming considerably larger we have no reason
      # to worry regardless of the execution environment.
      @file_contents = File.read(File.expand_path("../../data/#{@filename}.csv", __dir__))
      @table = prepend_id_column(CSV.parse(@file_contents, headers: true))

      @matcher = AVAILABLE_MATCHERS[matcher].new(@table.headers)

      raise ArgumentError, "Must supply a valid matcher. Valid matchers are: #{AVAILABLE_MATCHERS.keys.join(",")}" if @matcher.nil?
    end

    def run
      @index = Index.new(@table, @matcher).build_index

      # Need to establish the starting conditions
      current_entry = { value: "" }

      @index.each_with_index do |entry, i|
        report_progress(i)

        if @matcher.match?(current_entry[:value], entry[:value])
          @table[entry[:table_index]]["id"] = @table[current_entry[:table_index]]["id"]
        else
          current_entry = entry
          @table[current_entry[:table_index]]["id"] = SecureRandom.uuid if @table[current_entry[:table_index]]["id"].nil?
        end
      end

      File.write(File.expand_path("../../data/#{@filename}_result.csv", __dir__), @table.to_csv(write_headers: true))
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

    def report_progress(i)
      adjusted_index = i + 1
      return unless adjusted_index % 1000 == 0 || @index.length < 1000

      puts "Processing index_entry #{adjusted_index}/#{@index.length}"
    end
  end
end
