require 'sinatra'
require 'rubygems'
require 'httparty'
require 'mongo'
require 'json'

enable :sessions, :logging
set :raise_errors, false
set :show_exceptions, false
set :environment, :development
set :root, File.dirname(__FILE__)

config_data = YAML.load_file('config.yml')

get "/" do
  haml :index
end

get "/names.json" do
  connection = Mongo::Connection.new(config_data['mongo']['host'], config_data['mongo']['port'])
  db = connection.db('lb')
  db.authenticate(config_data['mongo']['user'], config_data['mongo']['password'])
  collection = db['data']
  data = collection.find.to_a
  data.collect {|d| d['name']}.uniq![0..10].to_json
end

get "/data.json" do
  connection = Mongo::Connection.new(config_data['mongo']['host'], config_data['mongo']['port'])
  db = connection.db('lb')
  db.authenticate(config_data['mongo']['user'], config_data['mongo']['password'])
  collection = db['data']
  data = collection.find.to_a
  names = {}
  data.each do |d|
    if names[d['name']]
      names[d['name']] << {x: d['date'], y: d['percentage']}
    else
      names[d['name']] = [{x: d['date'], y: d['percentage']}]
    end
  end
  names.collect { |k, d|  {name: k, data: d} }[0..10].to_json
end
