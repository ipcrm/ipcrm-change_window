module Puppet::Parser::Functions
  newfunction(
    :change_window,
    :doc  => "Provides change_window function that allows you to check current time against change window",
    :type => :rvalue
  ) do |args|
    class << self
      def change_window_time_is_within(s,e,c)
        #Hours
        if (s[0].to_i .. e[0].to_i).cover?(c[0].to_i)

          # Mins
          ## If mins are identical we are only comparing hours
          if s[1] != e[1]

            ## Check if our current minutes is within the change window range
            if (s[1].to_i .. e[1].to_i).cover?(c[1].to_i)
              return true
            end

          ## Since we are only comparing hours and have made it here
          ## we are wihin the change window
          else
            return true
          end
        end
          return false
      end
    end

    # args[0] TimeZone
    # args[1] Window Type - per_day or window(default)
    # args[2] Hash, window_wday
    # args[3] Hash, window_time

    # Validate Arguments are all present
    if args.length != 4
      raise Puppet::ParseError, "Invalid argument count, got #{args.length} expected 4"
    end

    # Set Timezone for other timestamp
    timezone = args[0]

    # Evaluation Type
    # per_day, or window
    # If per_day, we'll expect that window exists between start and end for each included
    # day.
    # If window, we'll expect that the window is continuous - from start day, start time through end day, end time.
    window_type = args[1].nil? ? 'window' : args[1]

    if !['window','per_day'].include?(window_type)
      raise Puppet::ParseError, "Window type must be 'window' or 'per_day'"
    end

    ## Change Window start and end weekday
    #Day of the week from 0, Sunday
    # Note use start 0 and end 0 for all week
    # (which  allows you to just have a time range every day)
    # Example: {'start' => 4, 'end' => 0}
    window_wday  = args[2]

    ## Stores window start end time
    #24Hour #Minute
    #Example: {'start' => ['17', '00'], 'end' => ['23', '00']}
    window_time = args[3]

    # Get Time (this will use localtime)
    t = Time.now.getlocal(timezone)


    if window_wday['end'] == 0 and window_wday['start'] != 0
      valid_days = (window_wday['start']..window_wday['start']+(6-window_wday['start'])).to_a.push(0).uniq
    else
      valid_days = (window_wday['start']..window_wday['end']).to_a.uniq
    end

    # Determine if this is multiday window
    if valid_days.include?(t.wday)

      # IF this is the first day of the window, adjust the end time to be 23:59 (ie the last possible minute of the day)
      if t.wday == window_wday['start']
        window_time['end'] = ['23','59']
        # IF we are within <start time> and 23:59 return true
        change_window_time_is_within(window_time['start'],window_time['end'],[t.hour,t.min]) == true ? true.to_s : false.to_s


      # IF this is the last day of the window, adjust to compare from 00:00 start time (ie first minute possible)
      elsif t.wday == window_wday['end']
        window_time['start'] = ['00','00']
        # IF we are within 00:00 and <end time> return true
        change_window_time_is_within(window_time['start'],window_time['end'],[t.hour,t.min]) == true ? true.to_s : false.to_s

      else
        if window_type == 'per_day'
          # If you've set per_day as your window type check if we are within the correct time
          change_window_time_is_within(window_time['start'],window_time['end'],[t.hour,t.min]) == true ? true.to_s : false.to_s

        else
          # If you've accepted the default window_type this is a continuous change window
          # Based on the above logic, this isn't the first day of the window, its not the last, but its within the valid_days
          # for your window.  Meaning, we don't care about time.  Its in your window.  Example: Start is Mon, End is Wed,
          # today is Tuesday.
          true.to_s
        end
      end
    # Your not within the valid_days
    else
      false.to_s
    end
  end
end
