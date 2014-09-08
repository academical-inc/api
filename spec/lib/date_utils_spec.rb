require 'spec_helper'

describe DateUtils do

  describe '.same_time?' do
    let(:t1) { DateTime.new(2015,1,15,11,0) }
    let(:t2) { DateTime.new(2014,6,14,11,0) }
    let(:t3) { DateTime.new(2015,1,15,17,30) }

    it 'should return true if the DateTime objects have the same time' do
      expect(DateUtils.same_time?(t1, t2)).to be true
    end

    it 'should return false if DateTime objects do not have the same time' do
      expect(DateUtils.same_time?(t1, t3)).to be false
      expect(DateUtils.same_time?(t2, t3)).to be false
    end
  end

  describe '.date_increment' do

    it 'should return the correct time increment for the given frequency' do
      expect(DateUtils.date_increment("YEARLY")).to   eq(1.year)
      expect(DateUtils.date_increment("MONTHLY")).to  eq(1.month)
      expect(DateUtils.date_increment("WEEKLY")).to   eq(1.week)
      expect(DateUtils.date_increment("DAILY")).to    eq(1.day)
      expect(DateUtils.date_increment("HOURLY")).to   eq(1.hour)
      expect(DateUtils.date_increment("MINUTELY")).to eq(1.minute)
      expect(DateUtils.date_increment("SECONDLY")).to eq(1.second)
    end

    it 'should fail when the frequency is invalid' do
      expect{DateUtils.date_increment("OTHERLY")}\
        .to raise_error(InvalidFrequencyError)
    end
  end

  describe '.dt_day_included_in' do
    let(:dt) { DateTime.now }
    let(:days) { [DateUtils::MO, DateUtils::WE, DateUtils::FR] }

    it 'it should return true when the date\'s day is included in days array' do
      mo = dt.monday
      we = mo + 2.days
      fr = we + 2.days

      expect(DateUtils.dt_day_included_in(mo, days)).to be(true)
      expect(DateUtils.dt_day_included_in(we, days)).to be(true)
      expect(DateUtils.dt_day_included_in(fr, days)).to be(true)
    end

    it 'should return false when the date\'s day is not included in days' do
      tu = dt.monday + 1.day
      th = tu + 2.days
      sa = th + 2.days

      expect(DateUtils.dt_day_included_in(tu, days)).to be(false)
      expect(DateUtils.dt_day_included_in(th, days)).to be(false)
      expect(DateUtils.dt_day_included_in(sa, days)).to be(false)
    end
  end

end
