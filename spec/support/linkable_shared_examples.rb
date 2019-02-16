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
