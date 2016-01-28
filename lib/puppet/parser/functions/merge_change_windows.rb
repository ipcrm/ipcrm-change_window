require 'date'

module Puppet::Parser::Functions
  newfunction(
    :merge_change_windows,
    :doc  => "Creates complex change windows by merging a series of windows together",
    :type => :rvalue
  ) do |args|

    # Validate arguments
    raise Puppet::ParseError, "Invalid argument count, got #{args.length} and expected 1" unless args.length == 1
    raise Puppet::ParseError, "Change_windows must be an array!" unless args[0].is_a? Array

    in_cw = false
    args[0].each { |cw|
      raise Puppet::ParseError, "Expect an Array for change_window entry, received #{cw.class}" unless cw.is_a? Array
      begin
        if function_change_window( cw ) == 'true'
          in_cw = true
        end
      rescue Exception => e
        # Catch exception and rebrand it as ours
        raise Puppet::ParseError, "change_window threw #{e.message}"
      end
    }
    return in_cw.to_s
  end
end
