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

describe SchoolTerm do

  describe 'instantiation' do
    let(:term) { build(:school_term) }

    it 'should instantiate a SchoolTerm' do
      expect(term.class.name.demodulize).to eq("SchoolTerm")
    end
  end

  describe 'validations' do

    it 'should be valid whith default values' do
      term = build(:school_term)
      expect(term).to be_valid
    end

    it 'should not be valid when dates are not correct' do
      term = build(:school_term, invalid:true)
      expect(term).not_to be_valid
    end

    it 'should not be valid when start_date is nil' do
      term = build(:school_term)
      term.start_date = nil
      expect(term).not_to be_valid
    end

    it 'should not be valid when end_date is nil' do
      term = build(:school_term)
      term.end_date = nil
      expect(term).not_to be_valid
    end

  end

end
