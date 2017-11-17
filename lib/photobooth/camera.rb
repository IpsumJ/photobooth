require 'gphoto2'
require 'photobooth/image'

class Photobooth
  class Camera
    class DummyCamera
      PREVIEW = "preview.jpg"
      CAPTURE = "capture.jpg"

      def capture_preview
        Image.new(File.read PREVIEW)
      end

      def capture
        Image.new(File.read CAPTURE)
      end

      def model
        "Dummy"
      end

      def close
      end
    end

    def self.find
      cams  = GPhoto2::Camera.all.map{|c| new c}
      cams.push DummyCamera.new
    end
    class << self
      private :new
    end

    def initialize gphoto_cam
      @cam = gphoto_cam
    end

    def capture_preview
      Image.new @cam.preview.data
    end

    def capture
      Image.new @cam.capture.data
    end

    def close
      @cam.close
    end
  end
end
