require 'gphoto2'
require 'photobooth/config'
require 'photobooth/image'
require 'photobooth/camera/dummy'
require 'photobooth/camera/mdummy'

class Photobooth
  class Camera
    def self.find
      cams  = GPhoto2::Camera.all.map{|c| new c}
      cams.push Dummy.new
      cams.push MDummy.new
    end
    class << self
      private :new
    end

    def initialize gphoto_cam
      @cam = gphoto_cam
      @lock = Mutex.new
    end

    def capture_preview
      @lock.synchronize do
        Image.new @cam.preview.data
      end
    end

    def capture
      @lock.synchronize do
        Image.new @cam.capture.data
      end
    end

    def model
      @cam.model
    end

    def close
      @cam.close
    end
  end
end
