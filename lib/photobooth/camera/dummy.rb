require 'photobooth/image'

class Photobooth
  class Camera
    class Dummy
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
  end
end
