#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
4. [Usage - Configuration options and additional functionality](#usage)
6. [Development - Guide for contributing to the module](#development)

## Overview

Provides change_window function that allows you to check current time against change windows you've defined.  


## Module Description

Why?

The original reason for this module was to use it in conjunction with the `trlinkin/noop` module.  

What happens is this function returns true or false (as a string) and you can use that input to your logic for noop. See [usage](#usage).

This module is actually made up of just one function, change_window.   


## Usage

Example Usage:

Where:
`$tz` is the timezone offset you want used when the current timestamp is generated.(this example is for EST)
`$window_wday` is a hash where start is the first weekday in your window and end is the last weekday - expressed as 0-6.  You can specify the same day if you like.
`$window_time` is a hash where start is an array and the 0 position is the start hour, the 1 position is the start minute. End is a key with another array as its value that sets the end hour and minute.
`$window_type` accepts to values: per_day or window.  `per_day` tells change_window that the hours specified are valid on each day specified.  For example if you set days 0-3 and start 20:00, end 23:00 - then Sunday through Wednesday from 8PM to 11PM this function will return true.  `window` (or actually any value but per_day) tells change_window to treat the days and times as a continuous change window spanning from start day/start time through end day/end time.

```puppet
$tz = "-05:00"
$window_wday  = { start => 5, end => 6 }
$window_time = { start  => ['20', '00'], end => ['23','00'] }
$window_type = 'window'
$val = change_window($tz, $window_type, $window_wday, $window_time)

if $val == 'false' {
    notify { "Puppet noop safety latch is enabled in site.pp!": }
    noop()
}
```

Another example shows wrapping the weekend.  You can specify combinations like below (days 5 - 0).  This will result in days 5,6,0 as being valid for the change window.  In this case I'm using per_day so on Friday, Saturday, or Sunday between 8PM and 11PM changes will be allowed.

```puppet
$tz = "-05:00"
$window_wday  = { start => 5, end => 0 }
$window_time = { start  => ['20', '00'], end => ['23','00'] }
$window_type = 'per_day'
$val = change_window($tz, $window_type, $window_wday, $window_time)

if $val == 'false' {
    notify { "Puppet noop safety latch is enabled in site.pp!": }
    noop()
}
```

You can also use hiera to enable more complex windows:

hiera:
```
tz_dev: "-05:00"
window_type_dev: per_day
window_wday_dev:
  start: 5
  end: 0
window_time_dev:
  start:
    - 20
    - 00
  end:
    - 23
    - 00
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
  notify { "Puppet noop safety latch is enabled for env ${e} in site.pp!": }
  noop()
}
```

## Development

Contributing via the normal means(fork/PR - add your tests!).  This code definitely could be improved.
