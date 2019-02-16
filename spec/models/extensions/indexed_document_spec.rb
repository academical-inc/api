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

describe IndexedDocument do

  describe '.unique_fields' do
    class DummyDoc
      include Mongoid::Document
      include IndexedDocument

      field :field1
      field :field2
      field :field3
      field :field4
      field :field5
      field :field6, type: Hash
      field :field7, type: Hash

      index({field1: 1, field2: 1}, {unique: true})
      index({field3: -1}, {unique: true})
      index({field4: 1})
      index({field5: -1, field3: 1})
      index({field4: 1, field3: 1}, {unique: true})
      index({"field6.field" => 1}, {unique: true})
      index({"field7.field" => 1, :field2 => 1}, {unique: true})
    end


    it 'should return the correct unique fields based on the mongoid indexes' do
      expect(DummyDoc.uniq_field_groups).to\
        eq([[:field1, :field2], [:field3], [:field4, :field3],
            [:"field6.field"], [:"field7.field", :field2]])
    end
  end

end

