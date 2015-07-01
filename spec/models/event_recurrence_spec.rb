require 'spec_helper'

describe EventRecurrence do

  describe 'instantiation' do
    let(:rec) { build(:event_recurrence) }

    it 'should instantiate an EventRecurrence' do
      expect(rec.class.name.demodulize).to eq("EventRecurrence")
    end
  end

  describe '#repeat_until' do
    let!(:rec) { build(:event_recurrence,
                       event: build(:event, :with_section)) }

    it 'should be in correct timezone' do
      expect(rec.repeat_until.utc_offset).to\
        eq(ActiveSupport::TimeZone.new(rec.event.timezone).utc_offset)
    end
  end

  describe '#update_rule' do
    let(:repeat_until) { DateTime.new(2015,5,15,11,0)\
                         .utc.strftime(EventRecurrence::ISO_FORMAT) }
    let(:expected_rule) { "RRULE:FREQ=WEEKLY;UNTIL=#{repeat_until}" }

    it 'should update the RRULE correctly when no days present' do
      rec = build(:event_recurrence, repeat_until: repeat_until)
      rec.update_rule
      expect(rec.rule).to eq expected_rule
    end

    it 'should update the RRULE correctly when days are present' do
      rec = build(:event_recurrence, repeat_until: repeat_until,
                  days_of_week: ["MO", "WE"])
      rec.update_rule
      expect(rec.rule).to eq "#{expected_rule};BYDAY=MO,WE"
    end
  end

  describe 'callbacks' do
    describe 'before creation' do
      let!(:rec) { build(:event_recurrence,
                         event: build(:event, :with_section)) }

      it 'should update the RRULE' do
        expect(rec).to receive :update_rule
        rec.save
      end
    end
  end

  describe 'validations' do

    it 'should be valid with default values' do
      rec = build(:event_recurrence, :with_days)
      expect(rec).to be_valid
    end

    it 'should not be valid when freq is not valid' do
      rec = build(:event_recurrence, freq: "OTHER")
      expect(rec).not_to be_valid
    end

    it 'should not be valid when repeat_until is not present' do
      rec = build(:event_recurrence, repeat_until: nil)
      expect(rec).not_to be_valid
    end

    it 'should not be valid when days_of_week is not valid' do
      rec = build(:event_recurrence, days_of_week: ["HU"] )
      expect(rec).not_to be_valid
      rec.days_of_week = ["MO", "TU", "WE", "TH", "FR", "SA", "SU", "OH"]
      expect(rec).not_to be_valid
      rec.days_of_week = ["MO", "TU", "WE", "TH", "FR", "SA", "SU", "MO"]
      expect(rec).not_to be_valid
      rec.days_of_week = ["MO", "TO"]
      expect(rec).not_to be_valid
    end
  end
end
