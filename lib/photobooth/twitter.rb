require 'twitter'
require 'photobooth/config'
require 'json'

class Photobooth
  class Twitter
    def initialize
      conf = JSON.parse File.read(Config['twitter_login'])
      @client = ::Twitter::REST::Client.new do |config|
        config.consumer_key = conf['consumer_key']
        config.consumer_secret = conf['consumer_secret']
        config.access_token = conf['access_token']
        config.access_token_secret = conf['access_token_secret']
      end
    end

    def tweet text, img: nil
      tweet = nil
      begin
      if img.nil?
        tweet = @client.update text
      else
        File.open(img) do |i|
          tweet = @client.update_with_media text, i
        end
      end
      rescue RuntimeError => e
        p e
      end
      tweet.nil? ? nil : tweet.url.to_s
    end
  end
end

if __FILE__ == $0
  x = Photobooth::Twitter.new
  #p x.tweet "Hello world! 3 with image #test", img: '../../capture.jpg'
  p x.tweet "Hello world! from config"
end
