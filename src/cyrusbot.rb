require "twitter"

#todo load from credentials.yml instead

Twitter.configure do |config|
  config.consumer_key = "LtOHVDSvhnDowChkHPaQ"
  config.consumer_secret = "slzYcUFLyY5b4igabsiywjaWSl6DO4SUtidLJR6Lfjs"
  config.oauth_token = "330381202-81Eak499zvhHfONzZ0sm0eQAfzix7sUITuZGt4C6"
  config.oauth_token_secret = "Nd5UCwPqkg07PfEVGlHrgksJzcMoTG5OMaMkVLV7c"
end

@client = Twitter::Client.new
@client.direct_messages.each do |message|
  @client.update "#{message.sender_screen_name}: #{message.text}"
  @client.direct_message_destroy message.id
end