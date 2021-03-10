require 'spec_helper'

tz = "-05:00"
time  = [2016,1,6,6,15] # 2016-01-06 06:15 (Wed)

Puppet::Util::Log.level = :debug
Puppet::Util::Log.newdestination(:console)

# Bad window_time
fail_wndw_type = 'windows'
fail_key_day   = {'starts' => '00:00', 'ends' => '23:59'}
fail_key_time  = {'starts' => '00:00', 'ends' => '23:59'}

# Build some test dates
pass_wndw_day  = {'start' => 2, 'end' => 4} # Window includes
fail_wndw_day  = {'start' => 1, 'end' => 2} # Window excludes
pass_one_day   = {'start' => 3, 'end' => 3} # One day includes
fail_one_day   = {'start' => 1, 'end' => 1} # One day excludes
pass_start_day = {'start' => 3, 'end' => 5} # Window starts on t
pass_end_day   = {'start' => 2, 'end' => 3} # Window ends on
pass_wrap_day  = {'start' => 6, 'end' => 4} # Weekend wrap includes
fail_wrap_day  = {'start' => 6, 'end' => 2} # Weekend wrap excludes
pass_all_days  = {'start' => 0, 'end' => 6} # All days valid
pass_string_days = {'start' => 'sUn', 'end' => 'SATurday'}
fail_string_days = {'start' => 'today', 'end' => 'tommorow'}

# Build some test times
pass_wndw_time       = {'start' => '06:15', 'end' => '06:30'} # Window includes
fail_wndw_time       = {'start' => '06:00', 'end' => '06:14'} # Window excludes
pass_wrap_time_start = {'start' => '06:00', 'end' => '05:00'} # Wrap includes start < t
pass_wrap_time_end   = {'start' => '11:00', 'end' => '06:15'} # Wrap includes end > t
pass_all_times       = {'start' => '00:00', 'end' => '23:59'} # All times valid
fail_time_format     = {'start' => '0000', 'end' => '2359'}   # Times missing colon (:)

# Test weeks
all_weeks = [1,2,3,4,5,6]
pass_week = [2] # 6th Jan 2016 = Week 2
fail_week = [1] # 6th Jan 2016 = Week 2
fail_weeks_non_array = 'foo'
fail_weeks_array_strings =  ['foo']
fail_weeks_array_float = [1.2]
fail_weeks_array_range_zero = [0,1] # is invalid
fail_weeks_array_range_high = [6,7] # 6 is invalid
pass_weeks_array_empty = []
pass_weeks_duplicates = [1,2,3,1]

# Test months
all_months = [1,2,3,4,5,6,7,8,9,10,11,12]
fail_months = [2] # time not in range
fail_months_range = ['2-4'] # time not in range
pass_months = [1]
pass_months_range = ['1-2']
pass_months_with_duplicates = [1,2,3,4,'1-2']
fail_month_format_string_array = ['foo']
fail_month_format_string = 'foo'
fail_month_format_float = [1.2]
fail_month_invalid_month_zero = [0]
fail_month_invalid_month_high = [13]
fail_month_invalid_range_zero = ['0-1']
fail_month_invalid_range_high = ['12-13']
fail_month_invalid_range = ['0-0']
fail_month_range_inverted = ['11-1'] # start must be before end of range
pass_month_empty_array = []

describe 'change_window::change_window' do
  # Test for parseError's
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(1).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(tz, fail_wndw_type, pass_all_days, all_weeks, all_months, pass_wndw_time).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(tz,'window', pass_all_days,pass_all_times, all_weeks, all_months, [2016,1,6,6,60]).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz,'window', fail_key_day,pass_all_times, all_weeks, all_months, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz,'window', pass_all_days,fail_key_time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz,'window', pass_all_days,fail_time_format).and_raise_error(Puppet::ParseError) }
  # Test optional args
  it { is_expected.to run.with_params(tz,'window', pass_all_days, pass_all_times) }
  it { is_expected.to run.with_params(tz,'window', pass_all_days, pass_all_times, all_weeks) }
  it { is_expected.to run.with_params(tz,'window', pass_all_days, pass_all_times, all_weeks, all_months) }
  # String days
  it { is_expected.to run.with_params(tz,'window', fail_string_days,pass_all_times).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz,'window', pass_string_days,pass_all_times, all_weeks, all_months, time).and_return("true") }
  # Test day-of-week (window)
  it { is_expected.to run.with_params(tz, 'window', pass_wndw_day,  pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', fail_wndw_day,  pass_all_times, all_weeks, all_months, time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'window', pass_one_day,   pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', fail_one_day,   pass_all_times, all_weeks, all_months, time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'window', pass_start_day, pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', pass_end_day,   pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', fail_one_day,   pass_all_times, all_weeks, all_months, time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'window', pass_wrap_day,  pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', fail_wrap_day,  pass_all_times, all_weeks, all_months, time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'window', pass_start_day, pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', pass_end_day,   pass_all_times, all_weeks, all_months, time).and_return("true") }
  # Test day-of-week (per_day)
  it { is_expected.to run.with_params(tz, 'per_day', pass_wndw_day,  pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'per_day', fail_wndw_day,  pass_all_times, all_weeks, all_months, time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_one_day,   pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'per_day', fail_one_day,   pass_all_times, all_weeks, all_months, time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_start_day, pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_end_day,   pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'per_day', fail_one_day,   pass_all_times, all_weeks, all_months, time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_wrap_day,  pass_all_times, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'per_day', fail_wrap_day,  pass_all_times, all_weeks, all_months, time).and_return("false") }
  # Test time-of-day (window)
  it { is_expected.to run.with_params(tz, 'window', pass_one_day,   pass_wndw_time, all_weeks, all_months,       time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', pass_one_day,   fail_wndw_time, all_weeks, all_months,       time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'window', pass_wndw_day,  pass_wndw_time, all_weeks, all_months,       time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', pass_wndw_day,  fail_wndw_time, all_weeks, all_months,       time).and_return("true") } # passes because mid-window
  it { is_expected.to run.with_params(tz, 'window', pass_start_day, pass_wrap_time_start, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', pass_end_day,   pass_wrap_time_end, all_weeks, all_months,   time).and_return("true") }
  # Test time-of-day (per_day)
  it { is_expected.to run.with_params(tz, 'per_day', pass_one_day,   pass_wndw_time, all_weeks, all_months,       time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_one_day,   fail_wndw_time, all_weeks, all_months,       time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_wndw_day,  pass_wndw_time, all_weeks, all_months,       time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_wndw_day,  fail_wndw_time, all_weeks, all_months,       time).and_return("false") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_start_day, pass_wrap_time_start, all_weeks, all_months, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'per_day', pass_end_day,   pass_wrap_time_end, all_weeks, all_months,   time).and_return("true") }
  # Test month of year
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, all_months, time).and_return("true")}
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, pass_months, time).and_return("true")}
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, pass_months_range, time).and_return("true")}
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_months, time).and_return("false")}
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_months_range, time).and_return("false")}
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_format_string, time).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_format_float, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, pass_months_with_duplicates, time).and_return("true") }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_format_string_array, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_invalid_month_zero, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_invalid_month_high, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_invalid_range_zero, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_invalid_range_high, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_invalid_range, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, fail_month_range_inverted, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, all_weeks, pass_month_empty_array, time).and_return("false") }
  # Test week of month
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, pass_week, all_months, time).and_return("true")}
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, fail_week, all_months, time).and_return("false")}
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, fail_weeks_non_array, all_months, time).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, fail_weeks_array_strings, all_months, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, fail_weeks_array_float, all_months, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, fail_weeks_array_range_zero, all_months, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, fail_weeks_array_range_high, all_months, time).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, pass_weeks_array_empty, all_months, time).and_return("false")}
  it { is_expected.to run.with_params(tz, 'window', pass_all_days,  pass_all_times, pass_weeks_duplicates, all_months, time).and_return("true")}

end
