require "oauth"

# This guy should eventually generate credentials.yml when it needs to.

@consumer = OAuth::Consumer.new("LtOHVDSvhnDowChkHPaQ", "slzYcUFLyY5b4igabsiywjaWSl6DO4SUtidLJR6Lfjs", {:site => "https://twitter.com/"})
@request_token = @consumer.get_request_token
puts @request_token.authorize_url

#@access_token = @request_token.get_access_token
