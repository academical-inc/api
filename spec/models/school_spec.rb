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

describe School do
  it_behaves_like Linkable, [:teachers, :sections, :students, :schedules]

  describe 'instantiation' do
    let(:school) { build(:school) }

    it 'should instantiate a School' do
      expect(school.class.name.demodulize).to eq("School")
    end
  end

  describe '#terms.latest' do
    let(:school) { build(:school) }

    it 'should return the most recent (latest) term' do
      latest = school.terms.latest
      expect(latest.start_date).to eq(Date.new(2015, 1, 15))
    end
  end

  describe '#set_utc_offset' do
    let(:school) { build(:school, timezone: "America/Bogota") }

    it 'sets utc_offset in minutes depending on timezone' do
      school.set_utc_offset
      expect(school.utc_offset).to eq(-300)
    end
  end

  describe 'callbacks' do

    describe 'before_save' do
      let(:school) { build(:school) }

      it 'inits utc_offset after creating school' do
        school.save!
        school.reload
        expect(school.utc_offset).not_to be_nil
      end

      it 'inits utc_offset after updating school' do
        school.save!
        school.update_attributes! timezone: "America/Bogota"
        school.reload
        expect(school.utc_offset).to eq(-300)
      end
    end

  end

  describe 'validations' do
    let!(:school) { build(:school) }

    it 'should be valid with default values' do
      expect(school).to be_valid
    end

    it 'should not be valid when departments is missing' do
      school.departments = []
      expect(school).not_to be_valid
      school.departments = [ build(:department, name: "") ]
      expect(school).not_to be_valid
    end

    it 'should not be valid when terms is missing' do
      school.terms = []
      expect(school).not_to be_valid
      school.terms = [ build(:school_term, name: "") ]
      expect(school).not_to be_valid
    end

    it 'should be invalid if timezone is not present' do
      school.timezone = nil
      expect(school).not_to be_valid
    end
  end
end
