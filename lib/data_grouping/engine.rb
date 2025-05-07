module DataGrouping
  class Engine
    def initialize(filename:, matcher:)
      # NOTE: Typically we'd only let trusted users run a script like this, but better
      # safe than sorry. This line tries to prevent malicious inputs from the user.
      raise ArgumentError, "Only allowed to access data files" if filename.match?(/(\.\. | ~ | -)/)

      homogenized_filename = filename.delete_suffix(".csv")
      @filename = File.read(File.join(__dir__, "..", "..", "data", "#{homogenized_filename}.csv"))

      @matcher = AVAILABLE_MATCHERS[matcher]

      raise ArgumentError, "Must supply a valid matcher. Valid matchers are: #{AVAILABLE_MATCHERS.keys.join(",")}" if @matcher.nil?
    end

    def run
      puts "I do nothing"
    end
  end
end
