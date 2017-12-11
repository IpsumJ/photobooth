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

    def tweete text, img: nil
      tweete = nil
      begin
      if img.nil?
        tweete = @client.update text
      else
        File.open(img) do |i|
          tweete = @client.update_with_media text, i
        end
      end
      rescue RuntimeError => e
        p e
      end
      tweete.nil? ? nil : tweete.url.to_s
    end
  end
end

if __FILE__ == $0
  x = Photobooth::Twitter.new
  #p x.tweete "Hello world! 3 with image #test", img: '../../capture.jpg'
  p x.tweete "Hello world! from config"
end
