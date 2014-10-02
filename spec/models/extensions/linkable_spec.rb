require 'spec_helper'

describe Linkable do

  describe '.linked_fields' do

    it 'should raise MethodMissingError if it has not been implemented' do
      expect{Linkable::ClassMethods.linked_fields}\
        .to raise_error(MethodMissingError)
    end
  end

end
