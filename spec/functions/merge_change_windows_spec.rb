require 'spec_helper'

# Setup some test variables
tz = "-05:00"
time  = [2016,1,6,6,15] # 2016-01-06 06:15 (Wed)
oTime = Time.new( *time, 0, tz)

# Bad window_time
fail_wndw_type = 'windows'
fail_key_day   = {'starts' => '00:00', 'ends' => '23:59'}
fail_key_time  = {'starts' => '00:00', 'ends' => '23:59'}

# Build some test dates
pass_wndw_day    = {'start' => 2, 'end' => 4} # Window includes
fail_wndw_day    = {'start' => 1, 'end' => 2} # Window excludes
pass_one_day     = {'start' => 3, 'end' => 3} # One day includes
fail_one_day     = {'start' => 1, 'end' => 1} # One day excludes
pass_start_day   = {'start' => 3, 'end' => 5} # Window starts on t
pass_end_day     = {'start' => 2, 'end' => 3} # Window ends on t
pass_wrap_day    = {'start' => 6, 'end' => 4} # Weekend wrap includes
fail_wrap_day    = {'start' => 6, 'end' => 2} # Weekend wrap excludes
pass_all_days    = {'start' => 0, 'end' => 6} # All days valid
pass_string_days = {'start' => 'sUn', 'end' => 'SATurday'}
fail_string_days = {'start' => 'today', 'end' => 'tommorow'}
fail_wknd_days   = {'start' => 6, 'end' => 0}
pass_wed_days    = {'start' => 3, 'end' => 3}
fail_tue_days    = {'start' => 2, 'end' => 2}

# Build some test times
pass_wndw_time       = {'start' => '06:15', 'end' => '06:30'} # Window includes
fail_wndw_time       = {'start' => '06:00', 'end' => '06:14'} # Window excludes
pass_wrap_time_start = {'start' => '06:00', 'end' => '05:00'} # Wrap includes start < t
pass_wrap_time_end   = {'start' => '11:00', 'end' => '06:15'} # Wrap includes end > t
pass_all_times       = {'start' => '00:00', 'end' => '23:59'} # All times valid
fail_time_format     = {'start' => '0000', 'end' => '2359'}   # Times missing colon (:)

# Test false, true yields true
pass_list_of_cws = [
  [tz, 'window', fail_wknd_days, pass_all_times, time],
  [tz, 'window', pass_wed_days,  pass_all_times, time],
]
# Test true, false yields true
pass_list_of_cws_rev = [
  [tz, 'window', pass_wed_days,  pass_all_times, time],
  [tz, 'window', fail_wknd_days, pass_all_times, time],
]
# Test false, false yields false
fail_list_of_cws = [
  [tz, 'window', fail_wknd_days, pass_all_times, time],
  [tz, 'window', fail_tue_days,  pass_all_times, time],
]
# window_type FAIL
fail_parse_bad_cw_args = [
  [tz, 'FAIL', pass_all_days, pass_all_times, time],
  [tz, 'window',  pass_all_days, pass_all_times, time],
]
# entry not an array
fail_parse_bad_cw_entry = [ tz, 'window', pass_all_days, pass_all_times, time]

describe 'merge_change_windows' do
  # Test for parseError's
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(fail_parse_bad_cw_args).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(fail_parse_bad_cw_entry).and_raise_error(Puppet::ParseError) }

  it { is_expected.to run.with_params(pass_list_of_cws).and_return("true") }
  it { is_expected.to run.with_params(pass_list_of_cws_rev).and_return("true") }
  it { is_expected.to run.with_params(fail_list_of_cws).and_return("false") }
end
