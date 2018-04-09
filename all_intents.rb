# Authors: Aarish Grover and Vyas Bhagwat

require './pizza'
require 'active_support/core_ext/array/conversions'


intent "HelpIntent" do
    response_text = ["I am Pizza Bot. I can order a new pizza, reorder from previous orders and track your order."]
    tell(response_text)
end

intent "LaunchRequest" do
    return tell("Please authenticate Pizza Bot from the Alexa app.", card: link_account_card) unless request.user_access_token_exists?
    
    user = User.authenticate(request.user_access_token)
    ask("Hi! I am Pizza Bot. Do you want to order a new pizza, reorder from previous orders, or track an order?")
end

intent "AddressIntent" do
    return tell("Please authenticate Pizza Bot from the Alexa app.", card: link_account_card) unless request.user_access_token_exists?
    user = User.authenticate(request.user_access_token)
    response_text = "OK. Do you want your order delivered to your home or office?"
    ask(response_text, session_attributes: { address: address })
end

intent "ContinueAddressIntent" do
    return tell("Please authenticate Pizza Bot from the Alexa app.", card: link_account_card) unless request.user_access_token_exists?
    user = User.authenticate(request.user_access_token)
    response_text = "OK. Your selected address is #{ address }. Please confirm by saying 'confirm address' or change the address by saying 'change address'."
    ask(response_text)
end

intent "TrackOrderIntent" do
    return tell("To track your order, please authenticate Pizza Bot via the Alexa app.", card: link_account_card) unless request.user_access_token_exists?
    
    user = User.authenticate(request.user_access_token)
    if user.pizzas.any?
        orders = user.pizzas.first(1).map { |order| "a #{ order.size } pizza with #{ order.toppings.to_sentence }" }
        response_text = ["Your order of #{ order.size } pizza with #{ order.toppings.to_sentence } is on it's way. "]
        else
        response_text = "You don't have any current orders. Place a new order by saying 'order a pizza'."
    end
    ask(response_text)
end


intent "PartyOrderIntent" do
    return tell("To order, please authenticate Pizza Bot via the Alexa app.", card: link_account_card) unless request.user_access_token_exists?
    
    user = User.authenticate(request.user_access_token)
    response_text = "Okay, party order it is. How many people in your party?"
    ask(response_text, session_attributes: { quantity: quantity })
end

intent "ContinuePartyOrderIntent" do
    return tell("To order, please authenticate Pizza Bot via the Alexa app.", card: link_account_card) unless request.user_access_token_exists?
    quantity = request.slot_value("quantity")
    user = User.authenticate(request.user_access_token)
    response_text = "OK a party of #{ quantity }. How would you like three large pepperoni pizzas? Say 'confirm my order' to confirm or 'start over' to start over"
    ask(response_text)
end


intent "StartOrderIntent" do
    pizza_sizes_string = Pizza::SIZES.to_sentence
    
    ask("What size of pizza would you like to order? You can choose from #{ Pizza::SIZES.to_sentence }")
end


intent "PrevOrdersIntent" do
    return tell("To list your orders, please authenticate Pizza Bot via the Alexa app.", card: link_account_card) unless request.user_access_token_exists?
    
    user = User.authenticate(request.user_access_token)
    if user.pizzas.any?
        orders = user.pizzas.first(4).map { |order| "a #{ order.size } pizza with #{ order.toppings.to_sentence }" }
        response_text = ["You have made #{ user.pizzas.count } orders. ",
        "#{ orders.to_sentence }. ",
        "Do you want to order from previous orders or create new pizza?"].join
        else
        response_text = "You don't have any previous orders. Place a new order by saying 'order a pizza'."
    end
    
    ask(response_text)
end


intent "ToppingsIntent" do
    response_text = [
    "Choose from the following toppings: ",
    "#{ Pizza::TOPPINGS.map { |topping| topping.to_s.gsub("_", " ") }.to_sentence }. "
    ].join
    
    ask(response_text)
end


intent "ContinueOrderIntent" do
    size = request.slot_value("size")
    response_text = ["OK, a #{ size } pizza. What toppings would you like on your pizza? ",
    "You can choose up to five toppings, or ask for a topping list.",
    ". Or, choose another size: #{ Pizza::SIZES.to_sentence }"].join
    
    ask(response_text, session_attributes: { size: size })
end


intent "FinalOrderIntent" do
    size = request.session_attribute('size')
    
    toppings = ['One', 'Two', 'Three', 'Four', 'Five'].inject([]) do |toppings, topping_number|
        topping = request.slot_value("topping#{ topping_number }")
        topping ? toppings + [topping] : toppings
    end
    
    disallowed_toppings = Pizza.disallowed_toppings(toppings)
    
    if disallowed_toppings.empty?
        ask("Sure, a #{ size } pizza with #{ toppings.to_sentence }. To confirm this order, say 'confirm my order'. To start over, say 'start over'", session_attributes: { size: size, toppings: toppings })
        else
        response_text = "I'm sorry, we don't have #{ disallowed_toppings.to_sentence }. You can choose your toppings again, or ask for a list of toppings."
        ask(response_text, session_attributes: { size: size })
    end
end


intent "ConfirmOrderIntent" do
   return tell("To confirm your order, please authenticate Pizza Bot via the Alexa app.", card: link_account_card) unless request.user_access_token_exists?
   address = request.slot_value("address")
  user = User.authenticate(request.user_access_token)
  pizza = user.pizzas.new(size: request.session_attribute('size'), toppings: request.session_attribute('toppings'))
  pizza.save

  response_text = ["Perfect! Your #{ pizza.size } pizza with #{ pizza.toppings.to_sentence } is on ",
  "its way to you at # { address }. Thank you for using Pizza Bot!"].join
  
  pizza_order = "You ordered a #{ pizza.size } pizza with #{ pizza.toppings.to_sentence }!"
  pizza_img = "https://www.cicis.com/media/1243/pizza_adven_zestypepperoni.png"
  pizza_card = card(pizza_order, pizza_img)

  tell(response_text, card: pizza_card)
end

    
intent "SessionEndedRequest" do
    respond("Hello World!")
end

