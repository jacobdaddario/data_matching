require "data_grouping/version"
require "data_grouping/engine"
require "data_grouping/email_matcher"

module DataGrouping
  # This is entirely unecessary. That said, it is nice to have, and
  # it let me show off some Ruby metaprogramming. Most importantly,
  # since it takes no user input, it's completely safe.
  AVAILABLE_MATCHERS = constants.filter_map do |constant|
    identifier = constant.name[/(.*)Matcher/, 1]
    next nil if identifier.nil?

    [identifier.downcase, constant]
  end.to_h
end

if __FILE__ == $0
  filename, matcher = *ARGV

  DataGrouping::Engine.new(filename:, matcher:).run
end
