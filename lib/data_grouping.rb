require "data_grouping/version"
require "data_grouping/engine"

module DataGrouping; end

if __FILE__ == $0
  filename, matcher = *ARGV

  DataGrouping::Engine.new(filename:, matcher:).run
end
