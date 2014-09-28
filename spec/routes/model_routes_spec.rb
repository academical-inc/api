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

  describe '.model_helpers' do

    it 'should return the correct helpers class' do
      expect(route_class.model_helpers).to eq(DummyModelHelpers)
    end
  end

  describe '.model_collection' do

    it 'should return the correct model uri collection e.g. dummy_models' do
      expect(route_class.model_collection).to eq(:dummy_models)
    end
  end

  describe '.model_singular' do

    it 'should return the correct singular model' do
      expect(route_class.model_singular).to eq(:dummy_model)
    end
  end

  describe '.model_base_route' do

    it 'should return the correct model base route' do
      expect(route_class.model_base_route).to eq("/dummy_models/:dummy_model_id")
    end
  end

end
