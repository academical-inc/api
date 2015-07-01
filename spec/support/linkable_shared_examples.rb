
shared_examples_for Linkable do |links|

  def assert_model_links(model, resource_name, fields)
    base_url = "/#{resource_name}/#{model._id}"
    expect(model.links.size).to eq(fields.size + 1)
    expect(model.links[:self]).to eq(base_url)
    fields.each do |field|
      expect(model.links[field]).to eq("#{base_url}/#{field}")
    end
  end

  let(:factory_name) { described_class.name.demodulize.underscore.to_sym }
  let(:class_name_for_url) { described_class.name.demodulize.underscore\
                             .pluralize }

  describe '#update_links' do
    let(:model) { build(factory_name) }

    it 'should update the links hash correctly' do
      expect(model.links).to eq({})
      model.update_links
      assert_model_links model, class_name_for_url, links
    end
  end

  describe 'validations' do
    let(:model) { build(factory_name) }

    it \
    '.linked_fields should be actual model relations' do
      described_class.linked_fields.each do |field|
        expect(model.respond_to?(field.to_sym)).to be(true),
          "#{field} not present in #{described_class}"
      end
    end
  end

  describe 'linkable model callbacks' do
    let(:model) { build(factory_name) }

    context 'before creation' do
      it 'should update the links' do
        expect(model).to receive :update_links
        model.save
      end
    end
  end

end
