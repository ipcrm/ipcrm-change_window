require 'spec_helper'

describe 'change_window' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params("-05:00",'per_day',{'start'=>0,'end'=>6},{'start'=>['00','00'],'end'=>['23','59']}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'window',{'start'=>0,'end'=>6},{'start'=>['00','00'],'end'=>['23','59']}).and_return("true") }
  it { is_expected.to run.with_params("-05:00",'per_day',{'start'=>0,'end'=>0},{'start'=>['00','00'],'end'=>['00','01']}).and_return("false") }
  it { is_expected.to run.with_params("-05:00",'window',{'start'=>0,'end'=>0},{'start'=>['00','00'],'end'=>['00','01']}).and_return("false") }
end
