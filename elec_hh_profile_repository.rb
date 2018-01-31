require 'sinatra'
require 'mongoid'
require 'rack/parser'
require 'logger'
require 'retries'
require_relative 'config/mongoid'

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require(f) }
class ElecHHProfileRepository < Sinatra::Application
  use Rack::Parser
  use Mongoid::QueryCache::Middleware

  set :raise_errors, true
  set :dump_errors, false
  set :show_exceptions, false
  enable :logging

  $logger = Logger.new(STDOUT)
  $logger.level = ENV['LOG_ENV'] ? ENV['LOG_ENV'].to_i : Logger::WARN

  def find_daily_data
    customer = Customer.find_or_create_by(name: to_slug(params['customer']))
    customer.find_daily_data params['supply_point_reference'], params[:date]
  end

  def get_supply_point
    customer = Customer.find_or_create_by(name: to_slug(params['customer']))
    customer.supply_points.find_or_create_by reference: params['supply_point_reference']
  end

  post '/:customer/supply-points/:supply_point_reference/:date' do
    $logger.info("received request to post #{request.url}")
    $logger.debug 'data posted'
    $logger.debug params['data']
    supply_point = nil
    with_retries(:max_tries => 5, :base_sleep_seconds => 1, :max_sleep_seconds => 2) do
      supply_point = get_supply_point
    end
    date = DateTime.parse(params['date'])
    ProfileDataPersister.new(supply_point, date).update_profile_data(params['data'])
    data_to_return = find_data_points(supply_point, date)
    $logger.debug 'data returned'
    $logger.debug data_to_return
    {status: 'OK', path: build_url, data: data_to_return}.to_json
  end

  post '/:customer/supply-points/:supply_point_reference/:date/duos' do
    date = DateTime.parse(params['date'])
    supply_point = nil
    with_retries(:max_tries => 5, :base_sleep_seconds => 1, :max_sleep_seconds => 2) do
      supply_point = get_supply_point
    end
    day = supply_point.days.where(date: date).first
    day.update_attributes params['day']
    day.update_data_points params['bands']
    day.save!
  end

  def find_data_points(supply_point, date)
    data_points = supply_point.days.where(date: date).first.data_points.map(&:to_hash)
    data_points.sort_by { |dp| dp['start'] }
  end

  get '/:customer/supply-points/:supply_point_reference/:date' do
    supply_point = nil
    with_retries(:max_tries => 5, :base_sleep_seconds => 1, :max_sleep_seconds => 2) do
      supply_point = get_supply_point
    end
    date = DateTime.parse(params['date'])
    result = supply_point.days.where(date: date).first
    result ? result.to_hash.to_json : {fixed:0, bands:[]}.to_json
  end

  get '/:customer/supply-points/:supply_point_reference/:date/bands' do
    supply_point = nil
    with_retries(:max_tries => 5, :base_sleep_seconds => 1, :max_sleep_seconds => 2) do
      supply_point = get_supply_point
    end
    data_points = find_data_points(supply_point, DateTime.parse(params['date']))
    {data: data_points}.to_json
  end

  get '/customers' do
    {data: Customer.all.sort(name: 1).map(&:to_hash)}.to_json
  end

  get '/customers/:customer_name/supply-points' do
    customer = Customer.find_by_name(params['customer_name'])
    customer.supply_points_list(params['page']).to_json
  end

  #only required for testing purposes
  delete '/:customer' do
    test_customers = %w(test-customer test-customer2)
    if test_customers.include? params['customer']
      Customer.where(name: params['customer']).destroy
    end
    200
  end

  get '/health' do
    HealthCheck.new.check_health
    'health check OK'
  end

  error BadRequest do |e|
    halt 400, e.message
  end

  error HealthCheckFailed do |e|
    halt 503, "Health check failed - #{e.message}"
  end

  private

  def build_url
    "/#{to_slug(params['customer'])}/supply-points/#{params['supply_point_reference']}/#{params['date']}"
  end

  def to_slug(str)
    str.downcase.tr(' ', '-')
  end

end