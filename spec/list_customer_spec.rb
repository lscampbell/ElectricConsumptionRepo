describe 'listing customers' do
  def post_the_data(data, customer)
    post "/#{customer}/supply-points/123456-098765/2016-01-01", {data: data}.to_json, {"CONTENT_TYPE" => "application/json"}
  end
  let(:posted) do
    [
        {
            'start' => DateTime.new(2016, 01, 01, 0, 0),
            'end' => DateTime.new(2016, 01, 01, 0, 30),
            'kwh' => 60.0
        },
        {
            'start' => DateTime.new(2016, 01, 01, 0, 30),
            'end' => DateTime.new(2016, 01, 01, 1, 0),
            'kwh' => 80.0
        }
    ]
  end
  before :each do
    post_the_data posted, 'test-customer-1'
    post_the_data posted, 'test-customer-3'
    post_the_data posted, 'test-customer-2'
    post_the_data posted, 'test-customer-4'
  end

  it 'returns the data sorted by name' do
    get '/customers'
    expect(last_response.status).to eq(200), "Error when listing customers - expected 200 got #{last_response.status}"
    actual = JSON.parse(last_response.body)['data']
    expected = [
        {'name' => 'test-customer-1'},
        {'name' => 'test-customer-2'},
        {'name' => 'test-customer-3'},
        {'name' => 'test-customer-4'}
    ]
    expect(actual).to eq (expected)
  end
end