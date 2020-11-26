require 'telegram/bot'
class Budget 
  attr_accessor :budget
  attr_accessor :expences

  def initialize(expences)
    @expences = expences
    #@budget = budget 
  end

  def take_budget(budget)
    @budget = budget
  end 

  def calculate(budget, another_number, options = {})
    budget.to_i
    another_number.to_i
    budget.to_i - another_number.to_i if options[:subtracked]
  end

  def calculate_expences(key, value)
    @expences = @expences.merge(key => value)
  end 

  def state_array(value)
    states = [0,1,2,3,4,5]
    state = s_array[value]
  end 
end 

token = '1443997139:AAGAwCO1Wgd9up7yhZXmIRxNW7zq30RAAFU'
states = 0
  Telegram::Bot::Client.run(token) do |bot|
    # b = Budget.new(1)
    # b.budget
    @b = Budget.new
    @b.expences = Hash.new 

    shoping_category = 'Shopping'
    house_category = 'House'
    entertaiment_category = 'Entertaiment'
    
    buttons_back = [ 
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Back', callback_data: 'back'),
    ] 
    markup_for_back = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons_back)  

    bot.listen do |message|
      case message
      when Telegram::Bot::Types::CallbackQuery
        case message.data
        when 'touch'
          bot.api.send_message(chat_id: message.from.id, text: "Please insert you budget, that you want to operate with")
          state = 1 
        when 'house'
          bot.api.send_message(chat_id: message.from.id, text: "Select the right amount you want to spent")
          state = 2
        when 'shoping'
          bot.api.send_message(chat_id: message.from.id, text: "Select the right amount you want to edit")
          state = 3  
        when 'back'
          bot.api.send_message(chat_id: message.from.id, text: "Select categories")
          state = 5
        end 
      when Telegram::Bot::Types::Message
        case message.text 
        when '/start'
          bot.api.send_message(chat_id: message.chat.id, text: 'Welcome to the bot, here you can plan you budget, to start please click on button')
          buttons_for_start_bot = [ 
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Start planing you budget', callback_data: 'touch')
          ] 
          markup_for_start_bot = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons_for_start_bot)
          bot.api.send_message(chat_id: message.chat.id, text: 'You can nivagate through bot usign: /start, /help, /budget', reply_markup: markup_for_start_bot)
        when 
          if state == 1 
            @b.take_budget(message.text)
            bot.api.send_message(chat_id: message.from.id, text: "Your budget is #{@b.budget}")
            buttons_for_select_categories = [ 
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{house_category}", callback_data: 'house'),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{shoping_category}", callback_data: 'shoping')
            ] 
            markup_for_select_categories = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons_for_select_categories)
            bot.api.send_message(chat_id: message.chat.id, text: 'Please select categories', reply_markup: markup_for_select_categories)
            state = 0 
          end
        when '/budget'
          if @b.budget.nil?
            bot.api.send_message(chat_id: message.from.id, text: "Your budget is empty")
          else 
            bot.api.send_message(chat_id: message.from.id, text: "Your budget is #{@b.budget}")
          end   
          bot.api.send_message(chat_id: message.from.id, text: "If you want to edit your budget click on button below or use /edit_budget")
        when 
          if state == 2
            house_new_budget = message.text.to_i
            @b.budget = @b.calculate(@b.budget.to_i, house_new_budget.to_i, subtracked: true)
            @b.expences.calculate_expences(house_category, house_new_budget)
            #@expences = @expences.merge{ house_category => house_new_budget }
            bot.api.send_message(chat_id: message.from.id, text: "Your budget is #{@b.budget}")
            bot.api.send_message(chat_id: message.from.id, text: "Click Back to get back for categories", reply_markup: markup_for_back)
            state = 0 
          end 
        when 
          if state == 3 
            shoping_new_budget = message.text.to_i
            @b.budget = @b.calculate(@b.budget.to_i, shoping_new_budget.to_i, subtracked: true)
            @expences = @expences.merge(shoping_category => shoping_new_budget)
            bot.api.send_message(chat_id: message.from.id, text: "Your budget is #{@b.budget}")
            bot.api.send_message(chat_id: message.from.id, text: "Click Back to get back for categories", reply_markup: markup_for_back)
            state = 0 
          end 
        when 
          if state == 5
            buttons_for_select_categories = [ 
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{house_category}", callback_data: 'house'),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{shoping_category}", callback_data: 'shoping')
            ] 
            markup_for_select_categories = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons_for_select_categories)
            bot.api.send_message(chat_id: message.chat.id, text: 'Please select  new categories', reply_markup: markup_for_select_categories)
            state = 0 
          end
        when '/month' 
          if @expences.nil?
            bot.api.send_message(chat_id: message.from.id, text: "Your expences no for month")   
          else 
            @expences.each do |k, v|
              bot.api.send_message(chat_id: message.from.id, text: "Your expences for #{k} is #{v}")
              month_expences = @expences.values.sum
              bot.api.send_message(chat_id: message.from.id, text: "Your expences for month is #{month_expences}")  
            end  
          end 
      

          #month_expences = expences.inject(0) {|sum, hash| sum + hash[:shopi]} #=> 30
          #{:amount => month_expences}  
 
            # month_expences.each do {|a| a++ } 
            # end 
          # month_expences.inject(0) {|sum, num| sum + num}
          # month_expences.to_s
          # month_expences.each do |i|
          # i.sum
          # month_expences.push(i)
             
          
         #new_array = restaurant_menu.keys

          #month_expences = expence
          #month_expences.map { |i| i.summ }

         # my_hash = Hash.new

            # my_key = "key000"
            # my_hash[my_key] = "my_value"
            # Livedemo: http://ideone.com/yqIx2M

            # Second one (more similar to what you are trying to achieve) is:

            # my_key = "key0"
            # my_hash = Hash[my_key, "value00"]
        else 
          bot.api.send_message(chat_id: message.chat.id, text: 'Type /start to using bot')
        end 
      end 
    end
  end


