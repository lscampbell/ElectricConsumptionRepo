require 'mongoid'
mongo_url = ENV['MONGO_URL'] || 'mongo:27017'
puts "mongo url : #{mongo_url}"

Mongoid.load_configuration(clients:
                             {
                               default: {
                                 database: "elec_hh_profile_#{ENV['RACK_ENV'] || 'development'}",
                                 hosts:    [mongo_url],
                                 options:  {
                                   max_pool_size:      16,
                                   min_pool_size:      1,
                                   wait_queue_timeout: 20,
                                   connect_timeout:    10
                                 }
                               }
                             })