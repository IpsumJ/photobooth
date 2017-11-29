require 'sdl'
require 'photobooth/config'

class Photobooth
  class UI
    def initialize notify_exit
      SDL.init SDL::INIT_VIDEO
      SDL::TTF.init
      @w, @h = 640, 480
      open_screen

      @clr_bg = @screen.format.mapRGB *Config[:background]
      @clr_txt = @screen.format.mapRGB *Config[:text_color]
      @clr_flash = @screen.format.mapRGB *Config[:flash_color]

      @text = nil

      @exit = notify_exit
      @onclick = []
      @image_grid = []
      @lock = Mutex.new
    end

    def run
      running = true
      while running
        e = SDL::Event.wait
        case e
        when SDL::Event::Quit
          @exit.quit
          running = false
        when SDL::Event::VideoResize
          @w = e.w
          @h = e.h
          open_screen
          clear_screen
        when SDL::Event::MouseButtonDown
          click_handler
        end
      end
    end

    def clear_screen
      @screen.fill_rect 0, 0, @w, @h, @clr_bg
    end
    private :clear_screen

    def open_screen
      @screen = SDL::Screen.open @w, @h, 0, SDL::SWSURFACE | SDL::RESIZABLE
      @font.close if @font
      @font = SDL::TTF.open(Config[:font], (@h * Config[:font_size]).to_i)
      @font.style = SDL::TTF::STYLE_NORMAL
      @font.hinting = SDL::TTF::HINTING_NORMAL
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
      clear_text if @text
      @text = txt.to_s
      @lock.synchronize do
        draw_text
      end
    end

    def draw_text
      return unless @text
      @font.draw_solid_utf8(@screen, @text, 0, 0, *Config[:text_color])
    end
    private :draw_text

    def clear_text
      @lock.synchronize do
        @text = nil
        clear_screen
      end
    end

    def flash
      delay = Config[:flash_time].to_f
      return if delay == 0
      @lock.synchronize do
        @screen.fill_rect 0, 0, @w, @h, @clr_flash
        @screen.flip
        sleep delay
        clear_screen
        @screen.flip
      end
    end

    def show_img img
      srf = SDL::Surface.loadFromIO img.io

      scl_x = @w.to_f / srf.w
      scl_y = @h.to_f / srf.h
      scl = scl_x < scl_y ? scl_x : scl_y

      @lock.synchronize do
        SDL::Surface.transform_draw srf, @screen, 0, scl, scl, 0, 0, @w/2, @h/2, SDL::Surface::TRANSFORM_TMAP
        draw_grid
        draw_text
        @screen.flip
      end
      srf.destroy
    end

    def show_img_grid img, n
      srf = SDL::Surface.loadFromIO img.io

      @image_grid << srf
      draw_grid
    end

    def draw_grid
      return if @image_grid.empty?
      pos = [[(@w * 1.0 / 4).to_i, (@h * 1.0 / 4).to_i],
             [(@w * 3.0 / 4).to_i, (@h * 1.0 / 4).to_i],
             [(@w * 1.0 / 4).to_i, (@h * 3.0 / 4).to_i],
             [(@w * 3.0 / 4).to_i, (@h * 3.0 / 4).to_i]]
      @image_grid.each_with_index do |srf, i|
        scl_x = @w.to_f / srf.w
        scl_y = @h.to_f / srf.h
        scl = (scl_x < scl_y ? scl_x : scl_y) * 0.99 * 0.5

        w, h = (srf.w * scl).ceil, (srf.h * scl).ceil
        x, y = pos[i][0] - w * 0.5, pos[i][1] - h * 0.5

        SDL::Surface.transform_draw srf, @screen, 0, scl, scl, 0, 0, *pos[i], SDL::Surface::TRANSFORM_TMAP
        @screen.draw_rect(x, y, w, h, 0x000000, false)
        @screen.draw_rect(x + 1, y + 1, w - 2, h - 2, 0xFFFFFF, false)
      end
      @screen.flip
    end
    private :draw_grid

    def clear_img_grid
      @lock.synchronize do
        @image_grid.each {|srf| srf.destroy}
        @image_grid = []
        clear_screen
      end
    end
  end
end
