#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
4. [Usage](#usage)
6. [Development - Guide for contributing to the module](#development)

## Overview

Provides change_window function that allows you to check current time against change windows you've defined.  


## Module Description

Why?

The original reason for this module was to use it in conjunction with the `trlinkin/noop` module.  However, you can actually use this function with any resource that you need to be sensitive to change windows by simply wrapping that resource declaration with some conditional logic.

This module is actually made up of just two functions, change_window and merge_change_windows.  The change_window function consumes your change window information (see [usage](#change_window)) and will return true or false (as a string).  The merge_change_windows function consumes an array of windows and tries each one.  If any one of the individual change_window returns 'true' then the merge_change_windows returns 'true'.  This allows construction of a complex change window with differing hours on differing days. Either function may be used within a module to make your decisions.

*IMPORTANT:* Remember that if you are _within_ the change window then the value returned is a String containing _'true'_, otherwise it returns _'false'_.

## change_window
### Usage
change_window( $tz, $window_type, $window_wday, $window_time, [$time])

Where:

`$tz` is the timezone offset you want used when the current timestamp is generated.(this example is for EST)

`$window_type` accepts to values: per_day or window.  
* `per_day` tells change_window that the hours specified are valid on each day specified.  For example if you set days 0-3 and start 20:00, end 23:00 - then Sunday through Wednesday from 8PM to 11PM this function will return true. For wrapped hours you receive start to midnight on the first day and midnight to end on the last day.
* `window` tells change_window to treat the days and times as a continuous change window spanning from start day/start time through end day/end time.
*  `$time` is an optional parameter that lets you specify the time to test as an array.  This array is passed to the Time.new() object to set the time under test.  This array should take the form of [ YYYY, MM, DD, HH, MM] and will apply the timezone specified.

`$window_wday` is a hash where start is the first weekday in your window and end is the last weekday - expressed as weekday names or 0-6.  You can specify the same day if you like and you may wrap the weekend (i.e friday .. monday).

`$window_time` is a hash where the start key is a timestamp (HH:MM), and end sets the end hour and minute. You may wrap the midnight hour (i.e. 22:00 .. 02:00). For per_day windows that wrap the midnight hour, the first day will apply the start-to-midnight and the last day will apply the midnight-to-end of the window.

```puppet
$tz = "-05:00"
$window_wday  = { start => 'Friday', end => 'Saturday' }
$window_time = { start  => '20:00', end => '23:00' }
$window_type = 'window'
$val = change_window($tz, $window_type, $window_wday, $window_time)

if $val == 'false' {
    notify { "Puppet noop enabled in site.pp! Not within change window!": }
    noop()
}
```

Another example shows wrapping the weekend.  You can specify combinations like below (days 5 - 0).  This will result in days 5,6,0 as being valid for the change window.  In this case I'm using per_day so on Friday, Saturday, or Sunday between 8PM and 11PM changes will be allowed.

```puppet
$tz = "-05:00"
$window_wday  = { start => 'Friday', end => 'Sunday' }
$window_time = { start  => '20:00', end => '23:00' }
$window_type = 'per_day'
$val = change_window($tz, $window_type, $window_wday, $window_time)

if $val == 'false' {
    notify { "Puppet noop enabled in site.pp! Not within change window!": }
    noop()
}
```

You can also use hiera to enable more complex windows:

hiera:
```
tz_dev: "-05:00"
window_type_dev: per_day
window_wday_dev:
  start: Friday
  end: Sunday
window_time_dev:
  start: "20:00"
  end: "23:00"
```

site.pp:
```puppet
$e = $::custom_env
$val = change_window(
         hiera("tz_${e}"),
         hiera("window_type_${e}"),
         hiera("window_wday_${e}"),
         hiera("window_time_${e}")
         )
if $val == 'false' {
  notify { "Puppet noop enabled in site.pp for env ${e}! Not within change window!": }
  noop()
}
```

## merge_change_windows
### Usage
merge_change_windows( $list_of_windows )

Where:

$list_of_windows is an Array made up of Arrays containing change_window parameters.

#### Manifest Example
```puppet
$tz = "-05:00"

# Friday @ 10 PM until Monday @ 2 AM
$window1_type = 'window'
$window1_wday = { start => 'Friday', end => 'Monday' }
$window1_time = { start => '22:00',  end => '02:00' }

# Wednesday @ 10 PM until Thursday @ 2 AM
$window2_type = 'window'
$window2_wday = { start => 'Wednesday', end => 'Thursday' }
$window2_time = { start => '22:00',     end => '02:00' }

change_windows = [
  [$tz, $window1_type, $window1_wday, $window1_time],
  [$tz, $window2_type, $window2_wday, $window2_time],
]

if merge_change_windows($change_windows) == 'true' {
  notify { "Puppet noop enabled in site.pp for env ${e}! Not within change window!": }
  noop()
}
```

#### Hiera Example
hiera:
```yaml
change_window_set::my_change_window:
  - # Friday @ 10 PM until Monday @ 2 AM
    - '-05:00'
    - 'window'
    - start: 'Friday'
      end:   'Monday'
    - start: '22:00'
      end:   '02:00'
    - # Wednesday @ 10 PM until Thursday @ 2 AM
      - '-05:00'
      - 'window'
      - start: 'Wednesday'
        end:   'Thursday'
      - start: '22:00'
        end:   '02:00'
```

site.pp:
```puppet
$change_window_set = 'my_change_window'
$change_windows    = hiera("change_window_set::${my_change_window}")

if merge_change_windows($change_windows) == 'false' {
  notify { "Puppet noop enabled in site.pp! Not within change window!": }
  noop()
}
```

## Development

Contributing via the normal means(fork/PR - add your tests!).  This code definitely could be improved.
