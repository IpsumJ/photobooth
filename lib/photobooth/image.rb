require 'rmagick'

class Photobooth
  class Image
    def initialize data
      @raw = data
      @rimg = Magick::Image.from_blob(@raw)[0]
    end

    def save
      raise NotImplementedError
    end

    def resized x, y
      scl_x = x / @rimg.columns.to_f
      scl_y = y / @rimg.rows.to_f
      scl = scl_x < scl_y ? scl_x : scl_y
      @rimg.resize(scl).to_blob
    end
  end
end
