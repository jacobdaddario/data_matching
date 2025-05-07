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

      @matcher = AVAILABLE_MATCHERS[matcher]

      raise ArgumentError, "Must supply a valid matcher. Valid matchers are: #{AVAILABLE_MATCHERS.keys.join(",")}" if @matcher.nil?
    end

    def run
      puts "I do nothing"
    end
  end
end
