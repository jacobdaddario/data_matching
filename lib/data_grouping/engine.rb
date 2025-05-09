require "csv"
require "securerandom"
require "data_grouping/index"
require "debug"

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
      current_chunk = []

      @index.each_with_index do |entry, i|
        report_progress(i)

        if @matcher.match?(current_entry[:value], entry[:value])
          current_chunk << entry
        else
          assign_chunk(current_chunk) if current_chunk.length > 1

          current_entry = entry
          current_chunk = [entry]
        end
      end

      # Have to assign the last chunk before exiting
      assign_chunk(current_chunk) if current_chunk.length > 1
      # Now, the only remaining rows have no matches and can be given unique IDs
      @table.each { |row| row["id"] = SecureRandom.uuid if row["id"].nil? }

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

    def assign_chunk(chunk)
      id = determine_id(chunk)

      # There's no overwriting concern here because we've already found
      # the existing ID
      chunk.each do |entry|
        @table[entry[:table_index]]["id"] = id
      end
    end

    def determine_id(chunk)
      existing_id = nil

      chunk.each do |entry|
        entry_id = @table[entry[:table_index]]["id"]

        if entry_id
          existing_id = entry_id
          break
        end
      end

      existing_id || SecureRandom.uuid
    end
  end
end
