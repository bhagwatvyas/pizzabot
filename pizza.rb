# Followed the tutorial here: https://developer.amazon.com/blogs/post/105df30e-9890-4a8c-9caf-5de1c8ff86cb/makers-academy-s-alexa-series-how-to-build-a-hello-world-skill-with-ruby
require 'data_mapper'
require 'dm-postgres-types'
require_relative './user'

class Pizza
  include DataMapper::Resource

  SIZES = [:small, :medium, :large]
  TOPPINGS = [
    :chicken,
    :bacon,
    :tomato_sauce, 
    :barbecue_sauce, 
    :cheese, 
    :ham,
    :pepperoni, 
    :mushrooms,
    :olives,
    :pineapple
  ]
  QUANTITY = [:two, :four, :six]
  property   :id, Serial
  property   :size, String
  property   :toppings, PgArray
  property   :quantity, String
  belongs_to :user

  def self.disallowed_toppings(toppings)
    toppings.reject { |topping| allowed_topping?(topping) }
  end

  private

  def self.allowed_topping?(topping)
    TOPPINGS.include? topping.gsub(" ", "_").to_sym
  end
end
