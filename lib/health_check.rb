require_relative './customer'
class HealthCheck
  def check_health
    begin
      Customer.all.first
    rescue Exception => e

      raise HealthCheckFailed, "cannot connect to MongoDB - #{e} - address: #{Mongoid.clients['default']['hosts'].first}"
    end
  end
end