require "data_grouping/version"
require "data_grouping/engine"
require "data_grouping/email_matcher"
require "data_grouping/phone_matcher"

module DataGrouping
  # This is entirely unnecessary. That said, it is nice to have, and
  # it lets me show off some Ruby metaprogramming. Most importantly,
  # it's completely safe since it takes no user input.
  AVAILABLE_MATCHERS = constants.filter_map do |constant|
    identifier = constant.to_s[/(.*)Matcher/, 1]
    next nil if identifier.nil?

    [identifier.downcase, const_get(constant)]
  end.to_h
end

if __FILE__ == $0
  filename, matcher = *ARGV

  DataGrouping::Engine.new(filename:, matcher:).run
end
