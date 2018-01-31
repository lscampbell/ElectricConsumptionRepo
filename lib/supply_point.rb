require 'mongoid'
class SupplyPoint
  include Mongoid::Document
  field :reference

  index( {reference: 1}, {unique: true, drop_dups: true})

  has_many :days, dependent: :destroy, class_name: 'SupplyPointDay'
  belongs_to :customer

  def find_daily date
    days.find_or_create_by date: date
  end

  def to_hash
    {reference: reference}
  end
end