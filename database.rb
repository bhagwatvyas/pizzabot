# Followed the tutorial here: https://developer.amazon.com/blogs/post/105df30e-9890-4a8c-9caf-5de1c8ff86cb/makers-academy-s-alexa-series-how-to-build-a-hello-world-skill-with-ruby
require 'data_mapper'
require './pizza'
require './user'

DataMapper.setup(:default, 'postgres://pizzabot@localhost/pizzabot')
DataMapper.finalize
Pizza.auto_migrate!
User.auto_migrate!
