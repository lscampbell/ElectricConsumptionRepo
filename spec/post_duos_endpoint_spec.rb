describe 'posting duos data' do
  def retrieve_the_data
    get '/test-customer/supply-points/123456-65432/2016-01-01'
    expect(last_response.status).to eq(200), "Error when retrieving profile data - expected 200 got #{last_response.status}"
    parsed = JSON.parse(last_response.body)
    {
        'fixed' => parsed['fixed'],
        'capacity_charge_rate' => parsed['capacity_charge_rate'],
        'exceeded_capacity_rate' => parsed['exceeded_capacity_rate'],
        'bands' => parsed['bands'].convert_dates
    }
  end

  let(:original_data) do
    [
        {
            start: DateTime.new(2016, 01, 01, 0, 0),
            end: DateTime.new(2016, 01, 01, 0, 30),
            kwh: 60.0
        },
        {
            start: DateTime.new(2016, 01, 01, 0, 30),
            end: DateTime.new(2016, 01, 01, 1, 0),
            kwh: 80.0
        }
    ]
  end
  let(:duos_bands) do
    [
        {
            start: DateTime.new(2016, 01, 01, 0, 0),
            end: DateTime.new(2016, 01, 01, 0, 30),
            duos_band:  'Green',
            duos_charge_per_kwh: 0.007,
            duos_unit_charge: 2.34
        },
        {
            start: DateTime.new(2016, 01, 01, 0, 30),
            end: DateTime.new(2016, 01, 01, 1, 0),
            duos_band:  'Red',
            duos_charge_per_kwh: 4.012,
            duos_unit_charge: 56.24
        }
    ]
  end

  let(:duos_data) do
    {
        day: {
            fixed: 123.43,
            capacity_charge_rate: 4.32,
            exceeded_capacity_rate: 5.23

        },
        bands: duos_bands
    }
  end

  before :each do
    post '/Test-Customer/supply-points/123456-65432/2016-01-01', {data: original_data}.to_json, {"CONTENT_TYPE" => "application/json"}
    post '/test-customer/supply-points/123456-65432/2016-01-01/duos', duos_data.to_json, {"CONTENT_TYPE" => "application/json"}
  end

  it 'posted the data without error' do
    expect(last_response.status).to eq(200), "Error when posting duos data - expected 200 got #{last_response.status}"
  end

  it 'can retrieve the data with the correct details' do
    actual = retrieve_the_data
    expected = {
        fixed: 123.43,
        capacity_charge_rate: 4.32,
        exceeded_capacity_rate: 5.23,
        bands: [
            {
                start: DateTime.new(2016, 01, 01, 0, 0),
                end: DateTime.new(2016, 01, 01, 0, 30),
                kwh: 60.0,
                duos_band:  'Green',
                duos_charge_per_kwh: 0.007,
                duos_unit_charge: 2.34
            },
            {
                start: DateTime.new(2016, 01, 01, 0, 30),
                end: DateTime.new(2016, 01, 01, 1, 0),
                kwh: 80.0,
                duos_band:  'Red',
                duos_charge_per_kwh: 4.012,
                duos_unit_charge: 56.24
            }
        ]
    }.deep_stringify_keys
    expect(actual).to eq(expected)
  end
end