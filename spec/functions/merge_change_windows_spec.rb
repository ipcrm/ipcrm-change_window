require 'spec_helper'

# Setup some test variables
tz = "-05:00"
time  = [2016,1,6,6,15] # 2016-01-06 06:15 (Wed)

# Build some test dates
pass_all_days    = {'start' => 0, 'end' => 6} # All days valid
fail_wknd_days   = {'start' => 6, 'end' => 0}
pass_wed_days    = {'start' => 3, 'end' => 3}
fail_tue_days    = {'start' => 2, 'end' => 2}

# Build some test times
pass_all_times       = {'start' => '00:00', 'end' => '23:59'} # All times valid

# Test weeks and months
all_weeks = [1,2,3,4,5]
all_months = [1,2,3,4,5,6,7,8,9,10,11,12]

# Test false, true yields true
pass_list_of_cws = [
  [tz, 'window', fail_wknd_days, pass_all_times,all_weeks, all_months, time],
  [tz, 'window', pass_wed_days,  pass_all_times,all_weeks, all_months, time],
]
# Test true, false yields true
pass_list_of_cws_rev = [
  [tz, 'window', pass_wed_days,  pass_all_times,all_weeks, all_months, time],
  [tz, 'window', fail_wknd_days, pass_all_times,all_weeks, all_months, time],
]
# Test false, false yields false
fail_list_of_cws = [
  [tz, 'window', fail_wknd_days, pass_all_times,all_weeks, all_months, time],
  [tz, 'window', fail_tue_days,  pass_all_times,all_weeks, all_months, time],
]
# window_type FAIL
fail_parse_bad_cw_args = [
  [tz, 'FAIL', pass_all_days, pass_all_times, all_weeks, all_months, time],
  [tz, 'window',  pass_all_days, pass_all_times, all_weeks, all_months, time],
]
# entry not an array
fail_parse_bad_cw_entry = [ tz, 'window', pass_all_days, pass_all_times, all_weeks, all_months, time]

describe 'change_window::merge_change_windows' do
  # Test for parseError's
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(1).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(fail_parse_bad_cw_args).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(fail_parse_bad_cw_entry).and_raise_error(Puppet::ParseError) }

  it { is_expected.to run.with_params(pass_list_of_cws).and_return("true") }
  it { is_expected.to run.with_params(pass_list_of_cws_rev).and_return("true") }
  it { is_expected.to run.with_params(fail_list_of_cws).and_return("false") }

end
