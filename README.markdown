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

This module is actually made up of just one function, change_window.  All the function does is consume you change window information (see [usage](#usage)) and return true or false(as a string).  This can be used to make decisions within your code.

*IMPORTANT* Remember that if your _within_ the change window the value returned is _true_, otherwise it returns _false_.

## Usage
Where:
`$tz` is the timezone offset you want used when the current timestamp is generated.(this example is for EST)
`$window_wday` is a hash where start is the first weekday in your window and end is the last weekday - expressed as weekday names or 0-6.  You can specify the same day if you like.
`$window_time` is a hash where the start key is a timestamp (HH:MM), and end sets the end hour and minute.
`$window_type` accepts to values: per_day or window.  `per_day` tells change_window that the hours specified are valid on each day specified.  For example if you set days 0-3 and start 20:00, end 23:00 - then Sunday through Wednesday from 8PM to 11PM this function will return true.  `window` (or actually any value but per_day) tells change_window to treat the days and times as a continuous change window spanning from start day/start time through end day/end time.

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

## Development

Contributing via the normal means(fork/PR - add your tests!).  This code definitely could be improved.
