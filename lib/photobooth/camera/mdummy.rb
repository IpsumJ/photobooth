require 'photobooth/image'

class Photobooth
  class Camera
    class MDummy
      DATASRC = "capture"

      def initialize
        @data = nil
        @start = Time.now
      end

      def load_data
        return if @data
        @data = []
        Dir.open(DATASRC).each do |frame|
          next unless /frame\d+\.jpg/ =~ frame
          @data << frame
        end
        @data.sort!
        @data.map! do |frame|
          Image.new(File.read(File.join(DATASRC, frame)))
        end
      end
      private :load_data

      def capture_preview
        get_frame
      end

      def capture
        get_frame
      end

      def get_frame
        load_data
        i = ((Time.now - @start) * 20).to_i % @data.size
        return @data[i]
      end
      private :get_frame

      def model
        "Moving Dummy"
      end

      def close
      end
    end
  end
end
