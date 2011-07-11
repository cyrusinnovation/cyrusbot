require "twitter"
require "yaml"

class Cyrusbot
  def create_client
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
  end
  
  def handle_direct_messages
    @client.direct_messages.each do |message|
      Cyrusbot.paginate_and_send message, @client
      @client.direct_message_destroy message.id
    end
  #  puts @client.rate_limit_status.remaining_hits.to_s
  end
  
  def autofollow_followers
    ids_to_befriend = @client.follower_ids.ids - @client.friend_ids.ids
    ids_to_befriend.each do |id|
      @client.follow id unless @client.friend_ids(id).ids.length >= 1000
    end
  end

  def self.paginate_and_send message, client
    intended_message = "#{message.sender_screen_name}: #{message.text}"
    if intended_message.length <= 140
      client.update intended_message
      return
    end
    
    # Twitter usernames are a maximum of fifteen characters, so we will never need to split a message into three parts.
    split_message_into_two_parts(message).each {|part| client.update part}
  end

  def self.split_message_into_two_parts(message)
    words = message.text.split
    if words.length == 1
      split_message_at_maximum_length(message)
    else
      split_message_at_word_boundary(message.sender_screen_name, words)
    end
  end

  private
  def self.split_message_at_maximum_length(message)
    extra_characters = "#{message.sender_screen_name}:  (1/2)"
    slice_point = 140 - extra_characters.length
    first_part = message.text[0...slice_point]
    second_part = message.text[slice_point...message.text.length]
    create_two_part_message(message.sender_screen_name, first_part, second_part)
  end

  def self.split_message_at_word_boundary(sender_screen_name, words)
    words.length.downto(1) do |slice_point|
      first_part = words[0...slice_point].join(" ")
      second_part = words[slice_point...words.length].join(" ")
      message_parts = create_two_part_message(sender_screen_name, first_part, second_part)
      return message_parts if message_parts[0].length <= 140
    end
  end

  def self.create_two_part_message(sender, first_part, second_part)
    ["#{sender}: #{first_part} (1/2)", "#{sender}: #{second_part} (2/2)"]
  end
end
