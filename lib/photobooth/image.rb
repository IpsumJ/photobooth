require 'rmagick'
require 'photobooth/config'

require 'base64'

class Photobooth
  class Image
    @@index = nil
    def initialize data
      @raw = data
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

    def save idx = nil
      idx = index unless idx
      path = File.join(Config[:output_dir], "%s_%04d.jpg" % [Time.now.strftime("%F"), idx])
      File.write(path, @raw)
      pr = Process.spawn 'exiftool', '-overwrite_original', '-all=', path
      Process.wait pr
    end

    def save_and_mark_to_tweet text
      idx = index
      spath = File.join(Config[:output_dir], "%s_%04d_small.jpg" % [Time.now.strftime("%F"), idx])
      File.write(spath, resized(1280, 1080))
      path = File.join(Config[:output_dir], "%s_%04d.tweet" % [Time.now.strftime("%F"), idx])
      File.write(path, text)
      pr = Process.spawn 'exiftool', '-overwrite_original', '-all=', spath
      Process.wait pr
      save idx
    end

    def io
      StringIO.new @raw
    end

    def resized x, y
      rimg = Magick::Image.from_blob(@raw)[0]

      scl_x = x / rimg.columns.to_f
      scl_y = y / rimg.rows.to_f
      scl = scl_x < scl_y ? scl_x : scl_y

      #rimg.resize!(x, y, Magick::TriangleFilter)
      #rimg.thumbnail!(scl)
      rimg.scale!(scl)
      rimg.to_blob
    end
  end
end
