require 'date'

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

    # Validate Args are correct type
    raise Puppet::ParseError, "TimeZone must be a string!"    unless args[0].is_a? String
    raise Puppet::ParseError, "Window type must be a string!" unless args[1].is_a? String
    raise Puppet::ParseError, "Window_wday must be a hash!"   unless args[2].is_a? Hash
    raise Puppet::ParseError, "Window_time must be a hash!"   unless args[3].is_a? Hash

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

    ## Setup the days of the week hash
    # First, validate that we got the keys we expect
    args[2].keys.each { |ww|
      if not ['start','end'].include?(ww)
        raise Puppet::ParseError, "The window_wday hash can include start and end only! Invalid value passed - #{ww}"
      end
    }

    # Now that we now we have valid keys, set local var equal to passed
    window_wday  = args[2]

    # Figure out what days have been passed & Convert non-int
    # Create new hash for storing ONLY int based days
    window_wday_int = Hash.new

    # For each day passed in, conver it from text to numeric
    # if numeric wasn't used
    for wdkey in window_wday.keys
      if window_wday[wdkey].is_a? String
        window_wday_int[wdkey] = Date::ABBR_DAYNAMES.map(&:downcase).find_index(window_wday[wdkey][0..2].downcase)
      elsif window_wday[wdkey].is_a? Integer
        window_wday_int[wdkey] = window_wday[wdkey]
      else
        raise Puppet::ParseError, "Invalid day found in supplied window days(its not a string or integer)"
      end
    end

    # One more validation - did we lookup valid values?
    window_wday_int.keys.each { |wi|
      if !window_wday_int[wi].is_a? Integer
        raise Puppet::ParseError, "Invalid day found in supplied window days"
      end

      if !(0..6).cover?(window_wday_int[wi])
        raise Puppet::ParseError, "Supplied weekday number is out of range (i.e. not 0-6) - value found #{window_wday_int[wi]}"
      end
    }

    ## Stores window start end time
    #24Hour #Minute
    #Example: {'start' => '17:00', 'end' => '23:00'}

    # Validate we got a usable time hash provided
    args[3].keys.each { |ts|
      if not ['start','end'].include?(ts)
        raise Puppet::ParseError, "Invalid key provided for window_time. Only start/end supported - found #{ts}"
      end

      if not args[3][ts] =~ /^\d(\d)?\:\d\d$/
        raise Puppet::ParseError, "Invalid time supplied for window_time #{ts} - found #{args[3][ts]}"
      end
    }

    # Now that we know its valid store it as a hash
    start_time = args[3]['start'].split(':').map(&:to_i)
    end_time   = args[3]['end'].split(':').map(&:to_i)
    window_time = {'start' => start_time, 'end' => end_time }

    # Get Time (this will use localtime)
    t = Time.now.getlocal(timezone)


    if window_wday_int['end'] == 0 and window_wday_int['start'] != 0
      valid_days = (window_wday_int['start']..window_wday_int['start']+(6-window_wday_int['start'])).to_a.push(0).uniq
    else
      valid_days = (window_wday_int['start']..window_wday_int['end']).to_a.uniq
    end

    # Determine if today is within the valid days for the change window
    if valid_days.include?(t.wday)

      # IF this is the first day of the window
      # And the window is multiple days
      # And the window is continuous (not per_day)
      # adjust the end time to be 23:59 (ie the last possible minute of the day)
      if t.wday == window_wday_int['start'] and valid_days.length > 1 and window_type != 'per_day'
        window_time['end'] = ['23','59']
        # IF we are within <start time> and 23:59 return true
        change_window_time_is_within(window_time['start'],window_time['end'],[t.hour,t.min]) == true ? true.to_s : false.to_s


      # IF this is the last day of the window, adjust to compare from 00:00 start time (ie first minute possible)
      # And the window is multiple days
      # And the window is continuous (not per_day)
      elsif t.wday == window_wday_int['end'] and valid_days.length > 1 and window_type != 'per_day'
        window_time['start'] = ['00','00']
        # IF we are within 00:00 and <end time> return true
        change_window_time_is_within(window_time['start'],window_time['end'],[t.hour,t.min]) == true ? true.to_s : false.to_s

      # If you've set window as your window type check and BUT thier is only 1 valid days
      elsif valid_days.length == 1 and window_type != 'per_day'
        change_window_time_is_within(window_time['start'],window_time['end'],[t.hour,t.min]) == true ? true.to_s : false.to_s

      # If you've set per_day as your window type check if we are within the correct time
      elsif window_type == 'per_day'
        change_window_time_is_within(window_time['start'],window_time['end'],[t.hour,t.min]) == true ? true.to_s : false.to_s

      else
        # If you've accepted the default window_type this is a continuous change window
        # Based on the above logic, this isn't the first day of the window, its not the last, but its within the valid_days
        # for your window.  Meaning, we don't care about time.  Its in your window.  Example: Start is Mon, End is Wed,
        # today is Tuesday.
        true.to_s
      end
    # Your not within the valid_days
    else
      false.to_s
    end
  end
end
