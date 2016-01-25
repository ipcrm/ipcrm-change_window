require 'spec_helper'

t = Time.now()

# Build some dynamic dates and times for testing
test_hour_start = t.hour - 1
test_hour_end   = t.hour + 1
test_hour_start = 0 if test_hour_start < 0
test_hour_end = 23 if test_hour_end > 23
test_day        = t.wday
test_wdw_start  = t.wday - 1
test_wdw_end    = t.wday + 2
test_wdw_start = 0 if test_wdw_start < 0
test_wdw_end = 6 if test_wdw_end > 6
today_d_range = {'start' => test_day,'end' => test_day}
test_d_range = {'start' => test_wdw_start, 'end' => test_wdw_end }

fail_d_start = t.wday + 1
fail_d_start = 6 if fail_d_start > 6
fail_d_end = t.wday + 2
fail_d_end = 0 if fail_d_end > 6
fail_d_range = {'start' => fail_d_start, 'end' => fail_d_end }
fail_today_range = {'start' => fail_d_start, 'end' => fail_d_start }
fail_hour_start = t.hour - 5
fail_hour_end   = fail_hour_start + 1
fail_hour_start = 0 if fail_hour_start < 0
fail_hour_end = 23 if fail_hour_end > 23

# End dynamic dates/times


describe 'change_window' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params("-05:00",'per_day',{'start'=>0,'end'=>6},{'start'=>'00:00','end'=>'23:59'}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'per_day',{'start'=>'Sunday','end'=>'Saturday'},{'start'=>'00:00','end'=>'23:59'}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'window',{'start'=>0,'end'=>6},{'start'=>'00:00','end'=>'23:59'}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'window',{'start'=>'sun','end'=>'sat'},{'start'=>'00:00','end'=>'23:59'}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'per_day',{'start'=>0,'end'=>0},{'start'=>'00:00','end'=>'00:00'}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'per_day',{'start'=>'Sunday','end'=>'sUn'},{'start'=>'00:00','end'=>'00:00'}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'window',{'start'=>0,'end'=>0},{'start'=>'00:00','end'=>'00:00'}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'window',{'start'=>'sun','end'=>'Tuesday'},{'start'=>'00:00','end'=>'23:59'}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'window',{'start'=>'sun','end'=>'Tuesday'},{'start'=>'00:00','end'=>'23:59'}).and_return("true") }

  it { is_expected.to run.with_params("-05:00",'window',{'start'=>'14','end'=>'Tuesday'},{'start'=>'00:00','end'=>'23:59'}).and_raise_error(Puppet::ParseError) }

  it { is_expected.to run.with_params("-05:00",'window',today_d_range,{'start'=>"#{test_hour_start}:#{t.min}",'end'=>"#{test_hour_end}:#{t.min}"}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'window',test_d_range,{'start'=>"#{test_hour_start}:#{t.min}",'end'=>"#{test_hour_end}:#{t.min}"}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'per_day',today_d_range,{'start'=>"#{test_hour_start}:#{t.min}",'end'=>"#{test_hour_end}:#{t.min}"}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'per_day',test_d_range,{'start'=>"#{test_hour_start}:#{t.min}",'end'=>"#{test_hour_end}:#{t.min}"}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'window',fail_d_range,{'start'=>"#{test_hour_start}:#{t.min}",'end'=>"#{test_hour_end}:#{t.min}"}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'window',fail_today_range,{'start'=>"#{test_hour_start}:#{t.min}",'end'=>"#{test_hour_end}:#{t.min}"}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'window',today_d_range,{'start'=>"#{fail_hour_start}:#{t.min}",'end'=>"#{fail_hour_end}:#{t.min}"}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'per_day',fail_d_range,{'start'=>"#{test_hour_start}:#{t.min}",'end'=>"#{test_hour_end}:#{t.min}"}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'per_day',fail_today_range,{'start'=>"#{test_hour_start}:#{t.min}",'end'=>"#{test_hour_end}:#{t.min}"}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'per_day',today_d_range,{'start'=>"#{fail_hour_start}:#{t.min}",'end'=>"#{fail_hour_end}:#{t.min}"}).and_return("false") }
end
