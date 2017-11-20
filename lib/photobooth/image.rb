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
        Dir.open(Config[:output_dir]).each do |file|
          m = /^\d{4}-\d{2}-\d{2}_(\d{4}).jpg$/.match(file)
          images << m[1].to_i if m
        end
        images.sort!
        @@index = images.size <= 0 ? 0 : images[-1]
        index
      else
        @@index += 1
      end
    end
    private :index

    def save
      path = File.join(Config[:output_dir], "%s_%04d.jpg" % [Time.now.strftime("%F"), index])
      File.write(path, @raw)
    end

    def resized x, y
      scl_x = x / @rimg.columns.to_f
      scl_y = y / @rimg.rows.to_f
      scl = scl_x < scl_y ? scl_x : scl_y
      @rimg.resize(scl).to_blob
    end
  end
end
