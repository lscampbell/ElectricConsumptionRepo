require 'json'
require 'spec_helper'

def retrieve_the_data
  get '/test-customer/supply-points/123456-098765/2016-01-01/bands'
  expect(last_response.status).to eq(200)
  JSON.parse(last_response.body)['data'].map {|dp| dp.merge 'start' => DateTime.parse(dp['start']), 'end' => DateTime.parse(dp['end'])}
end


describe 'posting profile data' do
  def post_the_data(data)
    post '/Test-Customer/supply-points/123456-098765/2016-01-01', { data: data }.to_json, { "CONTENT_TYPE" => "application/json" }
  end

  let(:original_data) do
    [
      {
        'start' => DateTime.new(2016, 01, 01, 0, 0),
        'end'   => DateTime.new(2016, 01, 01, 0, 30),
        'kwh'   => 60.0
      },
      {
        'start' => DateTime.new(2016, 01, 01, 0, 30),
        'end'   => DateTime.new(2016, 01, 01, 1, 0),
        'kwh'   => 80.0
      }
    ]
  end

  context 'after original post' do

    before :each do
      post_the_data(original_data)
    end

    it 'should be succcessful' do
      expect(last_response.status).to eq(200), "Error when posting profile data - expected 200 got #{last_response.status}"
    end

    it 'should return the original data and url in the response body' do
      actual         = JSON.parse(last_response.body)
      actual['data'] = actual['data'].map {|dp| dp.except('_id').merge('start' => DateTime.parse(dp['start']),
                                                                       'end'   => DateTime.parse(dp['end']))}
      expected       = { 'status' => 'OK', 'path' => '/test-customer/supply-points/123456-098765/2016-01-01', 'data' => original_data }
      expect(actual).to eq expected
    end

    it 'should be able to retrieve the dataset' do
      actual = retrieve_the_data
      expect(actual.map {|dp| dp.except('_id')}).to eq original_data.map {|d| d.stringify_keys}
    end

    it 'returns the correct information in the response' do
      actual = JSON.parse(last_response.body)

      expected = {
        'data'   => [
          {
            'start' => '2016-01-01T00:00:00.000Z',
            'end'   => '2016-01-01T00:30:00.000Z',
            'kwh'   => 60.0
          },
          {
            'start' => '2016-01-01T00:30:00.000Z',
            'end'   => '2016-01-01T01:00:00.000Z',
            'kwh'   => 80.0
          }
        ],
        'path'   => '/test-customer/supply-points/123456-098765/2016-01-01',
        'status' => 'OK'
      }
      expect(actual).to eq(expected)
    end

  end

  context 'after posting extra data to fill in gaps and change values' do
    let(:additional_and_updated_data) do
      [
        {
          start: DateTime.new(2016, 01, 01, 0, 0),
          end:   DateTime.new(2016, 01, 01, 0, 30),
          kwh:   75.0
        },
        {
          start: DateTime.new(2016, 01, 01, 1, 0),
          end:   DateTime.new(2016, 01, 01, 1, 30),
          kwh:   45.0
        }
      ]
    end
    let(:expected_data) do
      [
        {
          start: DateTime.new(2016, 01, 01, 0, 0),
          end:   DateTime.new(2016, 01, 01, 0, 30),
          kwh:   75.0
        },
        {
          start: DateTime.new(2016, 01, 01, 0, 30),
          end:   DateTime.new(2016, 01, 01, 1, 0),
          kwh:   80.0
        },
        {
          start: DateTime.new(2016, 01, 01, 1, 0),
          end:   DateTime.new(2016, 01, 01, 1, 30),
          kwh:   45.0
        }
      ]
    end
    before :each do
      post_the_data(original_data)
      post_the_data(additional_and_updated_data)
    end

    it 'should be able to retrieve merged data' do
      actual = retrieve_the_data
      expect(actual.map {|dp| dp.except('_id')}).to eq expected_data.map(&:stringify_keys)
    end
  end

  let(:posted_loss_data) do
    original_data.map {|dp| dp.merge(t_loss_factor: 1.01, t_loss: 6.03, d_loss_factor: 1.28, d_loss: 32.1)}
  end

  let(:posted_duos_data) do
    original_data.map {|dp| dp.merge(duos_charge_per_kwh: 0.01, duos_band: 'Red', duos_unit_charge: 1.28, fixed_charge: 4.35)}
  end

  context 'once losses have been posted' do
    before :each do
      post_the_data(original_data)
      post_the_data(posted_loss_data)
    end

    it 'retrieves the data with additional properties for losses' do
      retrieved = retrieve_the_data
      expect(retrieved.map {|dp| dp.except('_id')}).to eq posted_loss_data.map {|dp| dp.stringify_keys}
    end
  end

  context 'once duos has been posted' do
    before :each do
      post_the_data(original_data)
      post_the_data(posted_duos_data)
    end

    it 'retrieves the data with additional properties for duos' do
      expected = posted_duos_data.map {|dp| dp.stringify_keys}
      actual   = retrieve_the_data.map {|dp| dp.except('_id')}
      expect(actual).to eq expected
    end

    it 'returns the correct information in the duos response' do
      actual = JSON.parse(last_response.body)

      expected = {
        'data'   => [
          {
            'start'               => '2016-01-01T00:00:00.000Z',
            'end'                 => '2016-01-01T00:30:00.000Z',
            'kwh'                 => 60.0,
            'duos_band'           => 'Red',
            'duos_charge_per_kwh' => 0.01,
            'duos_unit_charge'    => 1.28,
            'fixed_charge'        => 4.35
          },
          {
            'start'               => '2016-01-01T00:30:00.000Z',
            'end'                 => '2016-01-01T01:00:00.000Z',
            'kwh'                 => 80.0,
            'duos_band'           => 'Red',
            'duos_charge_per_kwh' => 0.01,
            'duos_unit_charge'    => 1.28,
            'fixed_charge'        => 4.35
          }
        ],
        'path'   => '/test-customer/supply-points/123456-098765/2016-01-01',
        'status' => 'OK'
      }
      expect(actual).to eq(expected)
    end
  end
end