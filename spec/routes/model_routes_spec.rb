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

describe Academical::Routes::ModelRoutes do
  class DummyModel; end
  class DummyModelHelpers; end
  let(:route_class) { class DummyModels
                        extend Academical::Routes::ModelRoutes::ClassMethods
                      end }

  describe '.model' do

    it 'should return the correct model class' do
      expect(route_class.model).to eq(DummyModel)
    end

    it 'should raise error when route class name does not follow convention' do
      route_class.instance_variable_set(:@model, nil)
      allow(route_class).to receive(:name) { "XYZ" }
      expect{route_class.model}.to raise_error(InvalidModelRouteError)
    end
  end

  describe '.model_name' do

    it 'should return the correct model name' do
      expect(route_class.model_name).to eq("DummyModel")
    end
  end

  describe '.model_collection' do

    it 'should return the correct model uri collection e.g. dummy_models' do
      expect(route_class.model_collection).to eq(:dummy_models)
    end
  end

  describe '.model_singular' do

    it 'should return the correct model in singular e.g. dummy_model' do
      expect(route_class.model_singular).to eq(:dummy_model)
    end
  end

  describe '.model_base_route' do

    it 'should return the correct model base route' do
      expect(route_class.model_base_route).to eq("/dummy_models/:resource_id/?")
    end
  end

end
