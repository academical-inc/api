module Helpers

  def post_json(*args)
    post(*args, { 'CONTENT_TYPE' => 'application/json',
                  'ACCEPT' => 'application/json' })
  end

  def json_response(code=200)
    expect(last_response.status).to eq(code)

    json = ""
    expect {
      json = MultiJson.load(last_response.body)
    }.not_to raise_error, "JSON response is inavlid: #{last_response.body}"
    json.symbolize_keys!

    expect(json.key?(:data)).to be(true)
    json[:data]
  end

end
