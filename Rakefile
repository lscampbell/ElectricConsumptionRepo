require 'rubygems'
require 'mongoid'
require_relative 'elec_hh_profile_repository'

task :default => [:spec, :features]

namespace :mongo do
  task :create_indexes, :environment do |t, args|
    unless args[:environment]
      puts "Must provide an environment"
      exit
    end

    Customer.create_indexes
    SupplyPoint.create_indexes
    SupplyPointDay.create_indexes
  end
end