require_relative "cyrusbot"

bot = Cyrusbot.new
bot.create_client
bot.handle_direct_messages