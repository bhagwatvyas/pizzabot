# Followed the tutorial here: https://developer.amazon.com/blogs/post/105df30e-9890-4a8c-9caf-5de1c8ff86cb/makers-academy-s-alexa-series-how-to-build-a-hello-world-skill-with-ruby
require 'data_mapper'
require 'net/http'
require 'uri'
require 'json'
require_relative './pizza'

class User
  AMAZON_API_URL = "https://api.amazon.com/user/profile".freeze
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :access_token, Text
  property :address
  has n,   :pizzas

  def self.authenticate(access_token, client = Net::HTTP)
    uri = URI.parse("#{ AMAZON_API_URL }?access_token=#{ access_token }")
    first_name = JSON.parse(client.get(uri))["name"].split(" ").first
    first_or_create(name: first_name, access_token: access_token)
  end
end
