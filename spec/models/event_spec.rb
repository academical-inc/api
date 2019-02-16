#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

require 'spec_helper'

describe Event do
  let(:sdt) { DateTime.new(2015,1,14,11,0) }  # Wednesday
  let(:edt) { DateTime.new(2015,1,14,12,30) } # Wednesday

  def match_event_instance_to(built, sdt, edt, location, timezone)
    expect(built.start_dt).to eq(sdt)
    expect(built.end_dt).to   eq(edt)
    expect(built.location).to eq(location)
    expect(built.timezone).to eq(timezone)
  end

  describe 'instantiation' do
    let(:event) { build(:event) }

    it 'should instantiate an Event' do
      expect(event.class.name.demodulize).to eq("Event")
    end
  end

  describe '#start_dt' do
    let(:event) { create(:event, :with_section) }

    it 'should be in the correct timezone' do
      expect(event.start_dt.utc_offset).to\
        eq(ActiveSupport::TimeZone.new(event.timezone).utc_offset)
    end
  end

  describe '#end_dt' do
    let(:event) { create(:event, :with_section) }

    it 'should be in the correct timezone' do
      expect(event.end_dt.utc_offset).to\
        eq(ActiveSupport::TimeZone.new(event.timezone).utc_offset)
    end
  end

  describe '#expand' do
    let!(:event) { build(:event, :with_recurrence) }

    it 'should generate expanded array only when called for the first time' do
      expect(event).to receive(:generate_instances).and_call_original.once
      res1 = event.expand
      res2 = event.expand
      expect(res1.length).to be > 0
      expect(res1).to eq(res2)
    end

    it 'should return expanded array if it already exists' do
      event.instance_variable_set :@expanded, [event]
      expect(event).not_to receive(:generate_instances)
      expect(event.expand).to eq([event])
    end
  end

  describe '#serializable_hash' do
    let!(:event) { build(:event, :with_recurrence) }

    it 'should add @expanded instance var to hash representation if present' do
      event.expand
      as_jsn = event.as_json
      expect(as_jsn).to have_key("expanded")
    end

    it 'should not add @expanded var when it is not present' do
      expect(event.as_json).not_to have_key("expanded")
    end

    it 'should always add id field' do
      expect(event.as_json).to have_key("id")
    end
  end

  describe '#generate_instances' do
    let!(:event) { build(:event, :with_recurrence, start_dt: sdt, end_dt: edt) }

    it 'should return the same event when no recurrence present' do
      event.recurrence = nil
      expect(event.send(:generate_instances)).to be_nil
    end

    it 'should generate the correct events for the present recurrence' do
      event.recurrence.repeat_until = sdt + 3.weeks
      expected_dates = [
        [sdt, edt],
        [sdt + 5.days, edt + 5.days],
        [sdt + 1.week, edt + 1.week],
        [sdt + 1.week + 5.days, edt + 1.week + 5.days],
        [sdt + 2.weeks, edt + 2.weeks],
        [sdt + 2.weeks + 5.days, edt + 2.weeks + 5.days],
        [sdt + 3.weeks, edt + 3.weeks]
      ]
      result = event.send(:generate_instances)
      expect(result.length).to eq(expected_dates.length)
      result.each_with_index do |ev_inst, i|
        match_event_instance_to ev_inst, *expected_dates[i], event.location,
          event.timezone
      end
    end
  end

  describe '#generate_dates' do
    let(:event) { build(:event, start_dt: sdt, end_dt: edt) }

    context 'WEEKLY' do
      let(:dt_until) { sdt + 3.weeks }
      let(:weekly) { DateUtils::WEEKLY }

      it 'should generate correct dates when no days specified' do
        expected = [
          [sdt, edt],
          [sdt + 1.week, edt + 1.week],
          [sdt + 2.weeks, edt + 2.weeks],
          [dt_until, edt + 3.weeks]
        ]
        expect{|b| event.send(:generate_dates, weekly, dt_until, &b)}\
          .to yield_successive_args(*expected)
      end

      it 'should generate correct dates when days specified' do
        days = [DateUtils::WE, DateUtils:: FR]
        we_2_st = sdt + 1.week
        we_2_ed = edt + 1.week
        we_3_st = sdt + 2.weeks
        we_3_ed = edt + 2.weeks
        expected = [
          [sdt, edt], # current wednesday
          [sdt + 2.days, edt + 2.days], # next friday
          [we_2_st, we_2_ed], # 2nd wednesday
          [we_2_st + 2.days, we_2_ed + 2.days], #  2nd friday
          [we_3_st, we_3_ed], # 3rd wednesday
          [we_3_st + 2.days, we_3_ed + 2.days], # 3rd friday
          [dt_until, edt + 3.weeks] # last wednesday
        ]
        expect{|b| event.send(:generate_dates, weekly, dt_until, days:days, &b)}\
          .to yield_successive_args(*expected)
      end
    end

    context 'not WEEKLY' do

      it 'should generate correct dates when YEARLY' do
        dt_until = sdt + 3.years
        yrly = DateUtils::YEARLY
        expected = [
          [sdt, edt],
          [sdt + 1.year, edt + 1.year],
          [sdt + 2.years, edt + 2.years],
          [dt_until, edt + 3.years]
        ]
        expect{|b| event.send(:generate_dates, yrly, dt_until, &b)}\
          .to yield_successive_args(*expected)
      end

      it 'should generate correct dates when MONTHLY' do
        dt_until = sdt + 3.months
        mnthly = DateUtils::MONTHLY
        expected = [
          [sdt, edt],
          [sdt + 1.month, edt + 1.month],
          [sdt + 2.months, edt + 2.months],
          [dt_until, edt + 3.months]
        ]
        expect{|b| event.send(:generate_dates, mnthly, dt_until, &b)}\
          .to yield_successive_args(*expected)
      end

      it 'should generate correct dates when DAILY' do
        dt_until = sdt + 3.days
        dly = DateUtils::DAILY
        expected = [
          [sdt, edt],
          [sdt + 1.day, edt + 1.day],
          [sdt + 2.days, edt + 2.days],
          [dt_until, edt + 3.days]
        ]
        expect{|b| event.send(:generate_dates, dly, dt_until, &b)}\
          .to yield_successive_args(*expected)
      end
    end
  end

  describe '#generate_dates_by_days' do
    let(:untl)  { sdt + 3.weeks }
    let(:nxt_fr_st) { sdt + 2.days }
    let(:nxt_fr_ed) { edt + 2.days }
    let(:nxt_mo_st) { sdt.sunday + 1.day }
    let(:nxt_mo_ed) { edt.sunday + 1.day }
    let(:event)     { build(:event) }

    it 'should generate correct start/end dates for the week days specified' do
      days = [DateUtils::MO, DateUtils::WE, DateUtils:: FR]
      expect{|b| event.send(:generate_dates_by_days, sdt, edt, untl, days, &b)}\
        .to yield_successive_args([sdt, edt], [nxt_fr_st, nxt_fr_ed],
                                  [nxt_mo_st, nxt_mo_ed])
    end

    it 'shouldn\'t generate start/end dates for days not specified' do
      days = [DateUtils::MO, DateUtils:: FR]
      expect{|b| event.send(:generate_dates_by_days, sdt, edt, untl, days, &b)}\
        .to yield_successive_args([nxt_fr_st, nxt_fr_ed],
                                  [nxt_mo_st, nxt_mo_ed])
    end

    it 'should generate no start/end dates when no days specified' do
      days = []
      expect{|b| event.send(:generate_dates_by_days, sdt, edt, untl, days, &b)}\
        .not_to yield_control
    end

    it 'should generate dates only until specified "until date"' do
      days = [DateUtils::MO, DateUtils::WE, DateUtils:: FR]
      untls = [nxt_fr_st, sdt + 4.days]

      untls.each do |untl|
      expect{|b| event.send(:generate_dates_by_days, sdt, edt, untl, days, &b)}\
        .to yield_successive_args([sdt, edt], [nxt_fr_st, nxt_fr_ed])
      end
    end
  end

  describe '#build_instance_from_self' do
    let(:event) { build(:event, location: "Somewhere") }

    it 'should build an instance with the appropriate start/end datetimes' do
      built = event.send(:build_instance_from_self, sdt, edt)
      match_event_instance_to built, sdt, edt, "Somewhere", event.timezone
    end
  end

  describe 'validations' do
    let!(:event) { build(:event, :with_recurrence) }

    it 'it should be valid with default values' do
      expect(event).to be_valid
    end

    it 'should be invalid if start time and repeat until date time are diff' do
      event.recurrence.repeat_until = DateTime.new(2015,5,15,12,0)
      expect(event).not_to be_valid
    end

    it 'should be invalid if start_dt is missing' do
      event.start_dt = nil
      expect(event).not_to be_valid
    end

    it 'should be invalid if end_dt is missing' do
      event.end_dt = nil
      expect(event).not_to be_valid
    end

    it 'should be invalid if recurrence.repeat_until is missing' do
      event.recurrence.repeat_until = nil
      expect(event).not_to be_valid
    end

    it 'should be invalid if timezone is invalid' do
      event.timezone = "Invalid"
      expect(event).not_to be_valid
      expect(event.recurrence).to be_valid
    end

    it 'should be invalid if timezone is not present' do
      event.timezone = nil
      expect(event).not_to be_valid
    end
  end

end
