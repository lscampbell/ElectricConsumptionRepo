describe 'listing customers' do
  def post_the_data(data, supply_point_ref)
    post "/test-customer/supply-points/#{supply_point_ref}/2016-01-01", {data: data}.to_json, {"CONTENT_TYPE" => "application/json"}
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
    (12345..12377).each do |num|
      post_the_data posted, num.to_s
    end
  end

  it 'returns the data sorted by name 1st page when no page specified' do
    get '/customers/test-customer/supply-points'
    expect(last_response.status).to eq(200), "Error when supply points - expected 200 got #{last_response.status}"
    actual = JSON.parse(last_response.body).deep_symbolize_keys
    expected_rows = (12345..12359).map{|num| {reference: num.to_s}}
    expected = {data: expected_rows, total_pages: 3, current_page: 1, limit_value: 15}
    expect(actual).to eq (expected)
  end

  it 'returns the data sorted by name 1st page when page 1' do
    get '/customers/test-customer/supply-points?page=1'
    expect(last_response.status).to eq(200), "Error when supply points - expected 200 got #{last_response.status}"
    actual = JSON.parse(last_response.body).deep_symbolize_keys
    expected_rows = (12345..12359).map{|num| {reference: num.to_s}}
    expected = {data: expected_rows, total_pages: 3, current_page: 1, limit_value: 15}
    expect(actual).to eq (expected)
  end

  it 'returns the data sorted by name 1st page when page 2' do
    get '/customers/test-customer/supply-points?page=2'
    expect(last_response.status).to eq(200), "Error when supply points - expected 200 got #{last_response.status}"
    actual = JSON.parse(last_response.body).deep_symbolize_keys
    expected_rows = (12360..12374).map{|num| {reference: num.to_s}}
    expected = {data: expected_rows, total_pages: 3, current_page: 2, limit_value: 15}
    expect(actual).to eq (expected)
  end

 it 'returns the data sorted by name 1st page when page 3' do
    get '/customers/test-customer/supply-points?page=3'
    expect(last_response.status).to eq(200), "Error when supply points - expected 200 got #{last_response.status}"
    actual = JSON.parse(last_response.body).deep_symbolize_keys
    expected_rows = (12375..12377).map{|num| {:reference => num.to_s}}
    expected = {data: expected_rows, total_pages: 3, current_page: 3, limit_value: 15}
    expect(actual).to eq (expected)
  end
end