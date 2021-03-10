##### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
4. [Usage](#usage)
6. [Development - Guide for contributing to the module](#development)

## Overview

Provides change_window functionality that allows you to check current time against change windows and a defined type that applies noop() to classes when not within the change window.


## Module Description

Why?

The original reason for this module was to use it in conjunction with the `trlinkin/noop` module.  However, you can actually use the functions with any resource that you need to be sensitive to change windows by simply wrapping that resource declaration with some conditional logic.

The module is made up of two functions and a defined class.  The functions, [change_window](#change_window)() and [merge_change_windows](#merge_change_windows)(), allow the comparison of a change window schedule against the current time to determine if the run is within the change window ('true'), or outside the change window ('false').  The change_window function checks against a single window definition, while the merge_change_window function will check a list windows and return 'true' if any one of them is true.

The defined type [change_window::apply](#change_windowapply) will accept an array of change windows and a list of classes.  The class list is then included into the catalog with the noop() mode set appropriately.  This define is intended for use during role definition and allows change window control over some or all of the profiles within the role.  Keeping the role definition tidy and allowing some classes to function without change control.  A handy feature when you have changes that you wish applied all the time.

*IMPORTANT:* Remember that if you are _within_ the change window then the value returned by the functions is a String containing _'true'_, otherwise it returns _'false'_.

# Defined types
## change_window::apply
### Usage
```puppet
change_window::apply { 'my_controlled_changes':
  change_window_set => hiera('weekly_window'),
  class_list        => [ 'profile::ntp', 'profile::resolver' ],
}
```
where:

`change_window_set` = An array of arrays defining your change windows to check.  Most easily defined and retrieved via hiera (but does not have to be, see [merge_change_windows](#merge_change_windows) for details)

`class_list`        = an array of classes to include


The class_list will accept either simple class names to include or a hash describing the class/resource along with its parameters.

example class_list: with simple and parameterized classes
```
$class_list = [
  'profile::parameter_class' => {
    parm1 => 'value1',
    parm2 => 'value2',
  },
  'profile::simple_class',
]
```

# Functions
## change_window
### Usage
change_window( $tz, $window_type, $window_wday, $window_time, [$window_week], [$window_month], [$time])

Where:

- `$tz` is the timezone offset you want used when the current timestamp is generated.(this example is for EST)

- `$window_type` accepts to values: per_day or window.
  -  `per_day` tells change_window that the hours specified are valid on each day specified.  For example if you set days 0-3 and start 20:00, end 23:00 - then Sunday through Wednesday from 8PM to 11PM this function will return true. For wrapped hours you receive start to midnight on the first day and midnight to end on the last day.
  -   `window` tells change_window to treat the days and times as a continuous change window spanning from start day/start time through end day/end time.

- `$window_wday` is a hash where start is the first weekday in your window and end is the last weekday - expressed as weekday names or 0-6.  You can specify the same day if you like and you may wrap the weekend (i.e friday .. monday).

- `$window_time` is a hash where the start key is a timestamp (HH:MM), and end sets the end hour and minute. You may wrap the midnight hour (i.e. 22:00 .. 02:00). For per_day windows that wrap the midnight hour, the first day will apply the start-to-midnight and the last day will apply the midnight-to-end of the window.
- `$window_week` **OPTIONAL** array of weeks within a month to accept as within the change window. Values in the array must be of range 1-6. See 
- `$time` is an optional parameter that lets you specify the time to test as an array.  This array is passed to the Time.new() object to set the time under test.  This array should take the form of [ YYYY, MM, DD, HH, MM] and will apply the timezone specified.


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

### Week in Month Change Windows
Using the `$window_week` parameter in `change_window` you can specify a sub-set of weeks within each month to be 
accepted as valid change windows.

This parameter is optional, if not used all weeks are included

The parameter takes an Array of integers, between 1-6 as valid week definitions.

#### Example

Given the month is April 2021:
![window week example](img/window_week.png?raw=true "Window week example - April 2021")

Then:
- Week 1 runs from first of the month to the first Sunday
- Week 2 runs from the following Monday to the next Sunday
- etc...
- Last week of the month runs from final Monday to last day of the month

### Month in Year Change Windows
Using the `$window_month` parameter in `change_window` you can specify a sub-set of months within each year to be 
accepted as valid change windows.

This parameter is optional, if not used all months are included.

The parameter takes an array of integers and/or string ranges of values.

Months are represented by numerical values:

| Month     | Value |
| -----     | ----- |
| January   | 1     |
| February  | 2     |
| March     | 3     |
| April     | 4     |
| May       | 5     |
| June      | 6     |
| July      | 7     |
| August    | 8     |
| September | 9     |
| October   | 10    |
| November  | 11    |
| December  | 12    |

For example:
- Run only every other month: `[1,3,5,7,9,11]`
- Run only between January and March (inclusive): `[1,2,3]` or `['1-3']`

Individual values and ranges must only be between 1 and 12.

## Acknowledgements

- window_week functionality is provided through an extension which is a modified version of
  [week-of-month](https://github.com/sachin87/week-of-month)

## Development

Contributing via the normal means(fork/PR - add your tests!).
