require 'sdl'
require 'photobooth/config'

class Photobooth
  class UI
    def initialize
      SDL.init SDL::INIT_VIDEO
      @w, @h = 640, 480
      open_screen

      @clr_bg = @screen.format.mapRGB *Config[:background]
      @clr_txt = @screen.format.mapRGB *Config[:text_color]

      @onclick = []
      @text = nil
      @image_grid = []
    end

    def run
      running = true
      while running
        e = SDL::Event.wait
        case e
        when SDL::Event::Quit
          running = false
        when SDL::Event::VideoResize
          @w = e.w
          @h = e.h
          open_screen
        when SDL::Event::MouseButtonDown
          click_handler
        end
      end
    end

    def open_screen
      @screen = SDL::Screen.open @w, @h, 0, SDL::SWSURFACE | SDL::RESIZABLE
    end
    private :open_screen

    def click_handler
      @onclick.each do |b|
        b.call
      end
    end
    private :click_handler

    def register_onclick &block
      @onclick.push block
    end

    def display_text txt
      puts "Displaying #{txt}"
      return
      clear_text if @text
      fontsize = (@canvas.height * Config[:font_size].to_f).to_i
      @text = TkcText.new @canvas, (fontsize * 0.8).to_i, (fontsize * 0.8).to_i,
        :anchor => :center,
        :text => txt,
        :font => [Config[:font], fontsize],
        :fill => Config[:text_color]
      @text.raise
    end

    def clear_text
      return
      @text.delete
      @text = nil
    end

    def flash
      return
      delay = Config[:flash_time].to_f
      return if delay == 0
      white = TkcRectangle.new @canvas, 0, 0, @canvas.width, @canvas.height, :fill => Config[:flash_color]
      sleep delay
      white.delete
    end

    def show_img img
      srf = SDL::Surface.loadFromIO img.io

      scl_x = @w.to_f / srf.w
      scl_y = @h.to_f / srf.h
      scl = scl_x < scl_y ? scl_x : scl_y

      x = (@w - srf.w * scl) / 2.0
      y = (@h - srf.h * scl) / 2.0

      @screen.fill_rect 0, 0, @w, @h, @clr_bg
      SDL::Surface.transform_draw srf, @screen, 0, scl, scl, 0, 0, x, y, 0
      @screen.flip
      srf.destroy
    end

    def show_img_grid img, n
      return
      pos = [[(@canvas.width * 1.0 / 4).to_i, (@canvas.height * 1.0 / 4).to_i],
             [(@canvas.width * 3.0 / 4).to_i, (@canvas.height * 1.0 / 4).to_i],
             [(@canvas.width * 1.0 / 4).to_i, (@canvas.height * 3.0 / 4).to_i],
             [(@canvas.width * 3.0 / 4).to_i, (@canvas.height * 3.0 / 4).to_i]]
      w, h = @canvas.width / 2, @canvas.height / 2
      data = img.resized(w * 0.99, h * 0.99)
      tkimg = TkPhotoImage.new :data => data
      tkcimg = TkcImage.new @canvas, *pos[n], :anchor => :center, :image => tkimg

      @image_grid << tkcimg << tkimg
    end

    def clear_img_grid
      return
      @image_grid.each{|i| i.delete}
      @image_grid = []
    end
  end
end
