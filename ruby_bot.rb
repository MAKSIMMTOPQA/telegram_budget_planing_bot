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
end 

token = ''
states = 0
  Telegram::Bot::Client.run(token) do |bot|
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
            @expences = @expences.merge{ house_category => house_new_budget }
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
        else 
          bot.api.send_message(chat_id: message.chat.id, text: 'Type /start to using bot')
        end 
      end 
    end
  end


