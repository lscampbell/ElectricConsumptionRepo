require 'mongoid'
require 'kaminari/mongoid'
require_relative 'pagination'
class Customer
  include Mongoid::Document
  include Pagination

  field :name
  index({name: 1}, {unique: true, drop_dups: true})
  has_many :supply_points, dependent: :destroy, order: :reference.asc

  def self.find_by_name(name)
    self.find_by(name: name)
  end

  def find_daily_data supply_point_reference, date
    supply_point = supply_points.find_or_create_by reference: supply_point_reference
    supply_point.find_daily date
  end

  def supply_points_list(page = 1)
    paginate(supply_points.order(:reference.asc).page(page).per(15))
  end

  def to_hash
    {name: name}
  end
end