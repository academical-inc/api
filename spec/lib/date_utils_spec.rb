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

end
