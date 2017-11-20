require 'json'

class Photobooth
  class Config
    def self.load file
      @@conf = new file
    end

    def self.[] (key)
      @@conf[key]
    end

    class << self
      private :new
    end

    def initialize file
      @data = JSON.parse File.read(file)
    end

    def [] (key)
      x = @data[key]
      x = @data[key.to_s] if x.nil?
      x
    end
  end
end
