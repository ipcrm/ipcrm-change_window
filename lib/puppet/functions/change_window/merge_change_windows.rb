# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
require 'date'

# ---- original file header ----
#
# @summary
#   Creates complex change windows by merging a series of windows together
#
Puppet::Functions.create_function(:'change_window::merge_change_windows') do
  # @param args
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :args
  end


  def default_impl(*args)
    

    # Validate arguments
    raise Puppet::ParseError, "Invalid argument count, got #{args.length} and expected 1" unless args.length == 1
    raise Puppet::ParseError, "Change_windows must be an array!" unless args[0].is_a? Array

    in_cw = false
    args[0].each { |cw|
      raise Puppet::ParseError, "Expect an Array for change_window entry, received #{cw.class}" unless cw.is_a? Array
      begin
        if function_change_window_change_window( cw ) == 'true'
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
