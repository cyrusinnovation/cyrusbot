require "twitter"
require "yaml"

File.open(File.dirname(__FILE__) + "/credentials.yml") do |credentials_file| 
  @credentials = YAML.load(credentials_file)
end 

Twitter.configure do |config|
  config.consumer_key = @credentials["consumer_key"]
  config.consumer_secret = @credentials["consumer_secret"] 
  config.oauth_token = @credentials["oauth_token"]
  config.oauth_token_secret = @credentials["oauth_token_secret"] 
end

@client = Twitter::Client.new
@client.direct_messages.each do |message|
  @client.update "#{message.sender_screen_name}: #{message.text}"
  @client.direct_message_destroy message.id
end