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

module Helpers

  HEADERS = { 'CONTENT_TYPE' => 'application/json',
              'ACCEPT' => 'application/json' }.freeze

  def authorization_header(token)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end

  def payload(hash, root: :data)
    if root
      {"#{root}" => hash}.to_json
    else
      hash.to_json
    end
  end

  def post_json(path, *args)
    post path, payload(*args), HEADERS
  end

  def put_json(path, *args)
    put path, payload(*args), HEADERS
  end

  def current_student(student)
    allow_any_instance_of(Academical::Routes::Base).to receive(:current_student) { student }
  end

  def roles(roles)
    allow_any_instance_of(Academical::Routes::Base).to receive(:roles) { roles }
  end

  def make_logged_in(val)
    make_admin false
    make_student false
    allow_any_instance_of(Academical::Routes::Base).to receive(:logged_in?) { val }
  end

  def make_admin(val)
    allow_any_instance_of(Academical::Routes::Base).to receive(:is_admin?) { val }
  end

  def make_student(val, student=nil)
    make_admin false
    current_student student if not student.nil?
    allow_any_instance_of(Academical::Routes::Base).to receive(:is_student?) { val }
  end

  def expect_status(code)
    expect(last_response.status).to eq(code), "Expected #{code}, " +
      "Server responded: #{last_response.status} - #{last_response.body}"
  end

  def expect_correct_encoding
    expect(last_response.body.encoding.name).to eq("UTF-8")
  end

  def expect_correct_content_type
    expect(last_response.content_type).to eq("application/json;charset=utf-8")
  end

  def expect_correct_json
    json = ""
    expect {
      json = MultiJson.load(last_response.body)
    }.not_to raise_error, "JSON response is inavlid: #{last_response.body}"
    json.symbolize_keys
  end

  def json_response(code=200)
    expect_status code
    expect_correct_content_type
    expect_correct_encoding
    json = expect_correct_json

    expect(json[:success]).to be(true)
    expect(json).to have_key(:data)
    json[:data]
  end

  def json_error(code)
    expect_status code
    expect_correct_content_type
    expect_correct_encoding
    json = expect_correct_json

    expect(json[:success]).to be(false)
    expect(json).to have_key(:message)
    json[:message]
  end

  def json_error_with_data(code)
    expect_status code
    json = expect_correct_json

    expect(json[:success]).to be(false)
    expect(json).to have_key(:message)
    [json[:message], json[:data]]
  end

  def expect_camelized_response(response=json_response(200))
    case response
    when Hash
      response.each_pair do |key, val|
        expect(key).not_to include("_")
        expect_camelized_response val
      end
    when Array
      response.each do |v|
        expect_camelized_response v
      end
    end
  end

  def expect_nil
    expect(json_response).to be_nil
  end

  def expect_collection(length)
    json = json_response
    expect(json).to be_kind_of(Enumerable)
    expect(json.length).to eq(length)
    json
  end

  def expect_correct_model(model_id, code=200)
    json = json_response code
    expect(json["id"]).to eq(model_id.to_s)
    json
  end

  def expect_correct_models(ids)
    models = expect_collection ids.length
    ids.each do |id|
      res = models.select { |m| m["id"] == id.to_s }
      expect(res.length).to eq(1)
    end
    models
  end

  def expect_correct_model_objs(ids, models)
    objs = expect_collection ids.length
    models.each do |model|
      res = objs.select { |o| o.to_json == model.to_json }
      expect(res.length).to eq(1)
    end
  end

  def expect_model_to_be_created(model_class, &block)
    json = nil
    expect {
      block.call
      json = json_response(201)
      expect(json).to have_key("id")
      expect{model_class.find(json["id"])}.not_to raise_error
    }.to change(model_class, :count).by(1)
    json
  end

  def expect_model_to_be_updated(model_class, model_id, fields, &block)
    expect{block.call}.to change(model_class, :count).by(0)
    json = expect_correct_model model_id
    from_db = model_class.find(model_id)
    fields.each_pair do |key, value|
      expect(from_db.send(key.to_sym)).to eq(value)
      expect(json[key.to_s]).to eq(value)
    end
  end

  def expect_models_to_be_updated(model_class, to_update, &block)
    expect{block.call}.to change(model_class, :count).by(0)
    expect(json_response).to eq(to_update.count)
    to_update.each do |fields|
      from_db = model_class.find(fields["id"])
      fields.each_pair do |key, value|
        expect(from_db.send(key.to_sym)).to eq(value)
      end
    end
  end

  def expect_models_partially_updated(model_class, to_update, total, &block)
    expect{block.call}.to change(model_class, :count).by(0)
    msg, data = json_error_with_data 404
    expect(data).to eq(to_update.count)
    expect_documents_not_found_error total - to_update.count, total, msg
    to_update.each do |fields|
      from_db = model_class.find(fields["id"])
      fields.each_pair do |key, value|
        expect(from_db.send(key.to_sym)).to eq(value)
      end
    end
  end

  def expect_model_to_be_deleted(model_class, model_id, &block)
    expect{model_class.find(model_id)}.not_to raise_error
    expect{block.call}.to change(model_class, :count).by(-1)
    expect{model_class.find(model_id)}.to raise_error
    expect(json_response).to eq(true)
  end

  def expect_invalid_auth_error
    expect(json_error(401)).to eq("Invalid credentials. Please try again.")
  end

  def expect_not_authorized_error
    expect(json_error(403)).to eq("Not authorized")
  end

  def expect_not_found_error
    expect(json_error(404)).to eq("The resource was not found")
  end

  def expect_documents_not_found_error(not_found, total, actual_msg)
    expect(actual_msg).to eq(
      "#{not_found} out of #{total} resources where not found"
    )
  end

  def expect_invalid_path_error
    expect(json_error(404)).to eq("The requested path is unknown")
  end

  def expect_unknown_field_error(field)
    expect(json_error(422)).to eq(
      "The resource contains an unknown field: #{field}"
    )
  end

  def expect_validation_error
    expect(json_error(422)).to eq(
      "The data for the resource is incomplete or invalid"
    )
  end

  def expect_duplicate_error(fields)
    expect(json_error(422)).to eq(
      "A resource with the unique fields #{fields} already exists"
    )
  end

  def expect_missing_parameter_error(key=:data)
    expect(json_error(400)).to eq(
      "Required param '#{key}' is missing from the request"
    )
  end

  def expect_invalid_parameter_error(key=:data)
    expect(json_error(400)).to eq(
      "Required param '#{key}' is invalid"
    )
  end

  def expect_invalid_json_error
    expect(json_error(400)).to eq("Problems parsing JSON")
  end

  def expect_content_type_error
    expect(json_error(400)).to include(
      'The request Content-Type must be application/json'
    )
  end

  def get_factory_for(model, field)
    field_class_name = model.relations[field.to_s][:class_name]
    if not field_class_name.blank?
      field_class_name.demodulize.underscore.to_sym
    else
      field.to_s.singularize.underscore.to_sym
    end
  end

end
