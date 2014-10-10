module Helpers

  HEADERS = { 'CONTENT_TYPE' => 'application/json',
              'ACCEPT' => 'application/json' }.freeze

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

  def expect_status(code)
    expect(last_response.status).to eq(code), "Expected #{code}, " +
      "Server responded: #{last_response.status} - #{last_response.body}"
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
    json = expect_correct_json

    expect(json[:success]).to be(true)
    expect(json).to have_key(:data)
    json[:data]
  end

  def json_error(code)
    expect_status code
    json = expect_correct_json

    expect(json[:success]).to be(false)
    expect(json).to have_key(:message)
    json[:message]
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
    json = expect_collection ids.length

    models = json.collect do |model_data|
      expect(model_data).to have_key("data")
      model_data["data"]
    end
    ids.each do |id|
      res = models.select { |m| m["id"] == id.to_s }
      expect(res.length).to eq(1)
    end
  end

  def expect_model_to_be_created(model_class, &block)
    expect{block.call}.to change(model_class, :count).by(1)
    json = json_response(201)
    expect(json).to have_key("id")
    expect{model_class.find(json["id"])}.not_to raise_error
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

  def expect_not_found_error
    expect(json_error(404)).to eq("The resource was not found")
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

  def expect_missing_parameter_error(key=:data)
    expect(json_error(400)).to eq(
      "The parameter '#{key}' is missing from the request"
    )
  end

  def expect_invalid_json_error
    expect(json_error(400)).to eq("Problems parsing JSON")
  end

  def expect_duplicate_error(fields)
    expect(json_error(422)).to eq(
      "A resource with the unique fields #{fields} already exists"
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
