#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
4. [Usage](#usage)
6. [Development - Guide for contributing to the module](#development)

## Overview

Provides change_window function that allows you to check current time against change windows you've defined.  


## Module Description

Why?

The original reason for this module was to use it in conjunction with the `trlinkin/noop` module.  However, you can actually use the function withs any resource that you need to be sensitive to change windows by simply wrapping that resource declaration with some conditional logic.

This module is made up of two functions and a defined class.  The functions, [change_window](#change_window)() and [merge_change_windows](#merge_change_windows)(), allow the comparison of a change window schedule against the current time to determine if the run is within the change window ('true'), or outside the change window ('false').  The change_window function checks against a single window definition, while the merge_change_window function will check a list windows and return 'true' if any one of them is true.

The defined type [change_window::apply](#change_window::apply) will accept a hiera key and a list of classes.  The hiera key is used to lookup a list of change windows to check.  The class list is then included into the catalog with the noop() mode set appropriately.  This function is intended for use during role definition and allows change window control over some or all of the profiles within the role.  Keeping the role definition tidy and allowing some classes to function without change control.  A handy feature when you have changes that you wish applied all the time.

*IMPORTANT:* Remember that if you are _within_ the change window then the value returned by the functions is a String containing _'true'_, otherwise it returns _'false'_.

## Define: change_window::apply
### Usage
```puppet
change_window::apply { 'my_controlled_changes':
  change_window_set => 'weekly_window',
  class_list        => [ 'profile::ntp', 'profile::resolver' ],
}

where:
  change_window_set = hiera key to lookup change window definition
  class_list        = an array of classes to include
```
The change window definition follows the hiera example under merge_change_windows.  The class_list will accept either simple class names to include or a hash describing the class/resource along with its parameters.

example class_list: with simple and complex classes
```
$class_list = [
  'profile::parameter_class' => {
    parm1 => 'value1',
    parm2 => 'value2',
  },
  'profile::simple_class',
]
```

## Function: change_window()
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
```yaml
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

## Function: merge_change_windows()
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

if merge_change_windows($change_windows) == 'false' {
  notify { "Puppet noop enabled in site.pp! Not within change window!": }
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
