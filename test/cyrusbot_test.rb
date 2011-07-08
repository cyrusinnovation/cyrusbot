require "minitest/autorun"
require_relative "../src/cyrusbot"

class CyrusbotTest < MiniTest::Unit::TestCase
  def test_sends_ordinary_messages_with_attribution
    fake_client = FakeClient.new
    assert_equal([], fake_client.messages)
    Cyrusbot.paginate_and_send(FakeMessage.new("new message", "jbloggs"), fake_client)
    assert_equal(["jbloggs: new message"], fake_client.messages)
    Cyrusbot.paginate_and_send(FakeMessage.new("two message", "jbieber"), fake_client)
    assert_equal(["jbloggs: new message", "jbieber: two message"], fake_client.messages)
  end
  
  def test_splits_up_long_messages
    fake_client = FakeClient.new
    Cyrusbot.paginate_and_send(
            FakeMessage.new("A message that contains more than a hundred and forty characters in total when added together with the screen name of the sender.",
                            "thirty_four_characters_screen_name"), fake_client)
    assert_equal(["thirty_four_characters_screen_name: A message that contains more than a hundred and forty characters in total when added together with (1/2)",
                 "thirty_four_characters_screen_name: the screen name of the sender. (2/2)"], fake_client.messages)
  end
  
  def test_splits_up_messages_on_word_boundaries
    parts = Cyrusbot.split_message_into_two_parts(
            FakeMessage.new("word word word bird is the word; word word word bird is the word; word word word bird is the word; word word word bird is the word;", "the_trashmen"))
    assert_equal(["the_trashmen: word word word bird is the word; word word word bird is the word; word word word bird is the word; word word word bird (1/2)",
                  "the_trashmen: is the word; (2/2)"], parts)
  end
  
  def test_splits_single_word_messages_at_maximum_length
    parts = Cyrusbot.split_message_into_two_parts(
            FakeMessage.new("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", "4chan"))
    assert_equal(["4chan: ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu (1/2)",
                  "4chan: uuuuuuuuuuuu (2/2)"], parts)
  end
end

class FakeClient
  attr_accessor :messages
  
  def initialize
    @messages = []
  end
  
  def update message
    @messages << message
  end
end

class FakeMessage
  attr_accessor :text, :sender_screen_name
  
  def initialize text, sender_screen_name
    @text = text
    @sender_screen_name = sender_screen_name
  end
end