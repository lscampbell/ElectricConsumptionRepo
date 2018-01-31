require 'mongoid'
class SupplyPointDay
  include Mongoid::Document

  field :date, type: DateTime
  index date: 1

  field :fixed, type: Float
  field :capacity_charge_rate, type: Float
  field :exceeded_capacity_rate, type: Float

  belongs_to :supply_point

  embeds_many :data_points, class_name: 'ProfileDataPoint'

  def update_data_points data
    data.each do |d|
      data_point = find_data_point(d['start'], d['end'])
      data_point.merge(d.except('start', 'end'))
    end
  end

  def find_data_point(starts, ends)
    data_points.find_or_create_by(start: starts, end: ends)
  end

  def to_hash
    {
        fixed: fixed,
        capacity_charge_rate: capacity_charge_rate,
        exceeded_capacity_rate: exceeded_capacity_rate,
        bands: data_points.map(&:to_hash)
    }
  end
end