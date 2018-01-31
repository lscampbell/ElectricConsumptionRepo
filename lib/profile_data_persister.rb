require 'active_model'
require 'retries'
class ProfileDataPersister

  def initialize(supply_point, date)
    @supply_point = supply_point
    @date = date
  end

  def update_profile_data(data)
    with_retries(:max_tries => 5, :base_sleep_seconds => 1, :max_sleep_seconds => 2) do |attempt|
      $logger.debug "Attempt #{attempt} to update the profile data for #{@supply_point.reference}"
      day = @supply_point.days.find_or_create_by(date: @date)
      day.update_data_points(data)
      day.save!
    end
  end

end