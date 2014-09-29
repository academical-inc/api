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

  describe '.model_base_route' do

    it 'should return the correct model base route' do
      expect(route_class.model_base_route).to eq("/dummy_models/:resource_id")
    end
  end

  describe '.model_update_route' do

    it 'should return the correct model base route' do
      expect(route_class.model_update_route).to eq("/dummy_models/?:resource_id?")
    end
  end

end