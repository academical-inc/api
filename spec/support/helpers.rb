module Helpers

  HEADERS = { 'CONTENT_TYPE' => 'application/json',
              'ACCEPT' => 'application/json' }.freeze

  def post_json(*args)
    post(*args, HEADERS)
  end

  def put_json(*args)
    put(*args, HEADERS)
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
    expect(json_response(201)).to have_key("id")
  end

  def expect_model_to_be_updated(model_class, model_id, fields, &block)
    expect{block.call}.to change(model_class, :count).by(0)
    json = expect_correct_model model_id
    fields.each_pair do |key, value|
      expect(json[key.to_s]).to eq(value)
    end
  end

  def expect_not_found
    expect(json_error(404)).to eq("The resource was not found")
  end

  def expect_unknown_field_error
    expect(json_error(422)).to eq(
      "The data for the resource contains an unknown field"
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

end
