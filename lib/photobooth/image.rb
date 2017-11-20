require 'rmagick'
require 'photobooth/config'

class Photobooth
  class Image
    @@index = nil
    def initialize data
      @raw = data
      @rimg = Magick::Image.from_blob(@raw)[0]
    end

    def index
      if @@index.nil?
        images = []
        Dir.open.Config[:output_dir].each do |file|
          m = /^\d{4}-\d{2}-\d{2}_(\d{4}).jpg$/
          images << m[1].to_i if m
        end
        images.sort!
        @@index = images[-1]
      else
        @@index += 1
      end
    end
    private :index

    def save
      $stderr.puts "Save not implemented"
      path = File.join(Config[:output_dir], "#{Time.now.strftime "%f"}_#{index})
      puts "Saving to #{Config[:output_dir]}"
    end

    def resized x, y
      scl_x = x / @rimg.columns.to_f
      scl_y = y / @rimg.rows.to_f
      scl = scl_x < scl_y ? scl_x : scl_y
      @rimg.resize(scl).to_blob
    end
  end
end
