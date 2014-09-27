module Helpers

  def post_json(*args)
    post(*args, { 'CONTENT_TYPE' => 'application/json',
                  'ACCEPT' => 'application/json' })
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

  def json_error(code=404)
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

  def expect_correct_model(model_id)
    expect(json_response["id"]).to eq(model_id.to_s)
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

  def expect_not_found
    expect(json_error).to eq("The resource was not found")
  end

end
