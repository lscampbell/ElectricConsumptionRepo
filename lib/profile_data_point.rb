require 'mongoid'
class ProfileDataPoint
  include Mongoid::Document

  field :start, type: DateTime
  field :end, type: DateTime


  embedded_in :supply_point_day

  [:kwh, :t_loss_factor, :t_loss, :d_loss_factor, :d_loss, :duos_charge_per_kwh, :duos_unit_charge,
   :fixed_charge, :raw, :lead, :lag].each do |sym|
    field sym, type: Float
  end

  [:duos_band, :units].each do |key|
    field key, type: String
  end

  field :estimated, type: Boolean

  def merge(hash)
    hash.except('start', 'end', '_id').each do |k, v|
      send("#{k}=", v)
    end
  end

  def to_hash
    result = {}
    [:kwh, :t_loss_factor, :t_loss, :d_loss_factor, :d_loss,
     :duos_band, :duos_charge_per_kwh, :duos_unit_charge, :fixed_charge].each do |key|
      value = send(key)
      result[key.to_s] = value if value
    end
    [:start, :end].each do |key|
      value = send(key)
      result[key.to_s] = value.utc if value
    end
    result
  end
end