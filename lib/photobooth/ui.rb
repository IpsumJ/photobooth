require 'tk'
require 'tk/canvasfix'
require 'tkextlib/tkimg'
require 'base64'

class Photobooth
  class UI
    def initialize
      @root = TkRoot.new
      @root.title = "Photobooth"
      @root.width = 640
      @root.height = 480
      @canvas = TkCanvas.new @root, :background => "black", :highlightthickness => 0
      @canvas.pack :fill => "both", :expand => "yes"
      @canvas.bind(:Configure) do |e|
        @canvas.width = e.width
        @canvas.height = e.height
        @image.coords = [e.width / 2, e.height / 2] if @image
      end
      @canvas.bind("Button-1"){click_handler}
      @onclick = []
      @text = nil
      @image = nil
      @image_grid = []
    end

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
      fontsize = (@canvas.height * 0.15).to_i
      @text = TkcText.new @canvas, (fontsize * 0.8).to_i, (fontsize * 0.8).to_i,
        :anchor => :center,
        :text => txt,
        :font => ["Sans", fontsize],
        :fill => "red"
      @text.raise
    end

    def clear_text
      @text.delete
      @text = nil
    end

    def flash
      white = TkcRectangle.new @canvas, 0, 0, @canvas.width, @canvas.height, :fill => "White"
      sleep 0.1
      white.delete
    end

    def show_img img
      data = Base64.encode64(img.resized(@canvas.width, @canvas.height))
      old_img = @tkimg
      @tkimg = TkPhotoImage.new :data => data
      if @image.nil?
        @image = TkcImage.new @canvas, @canvas.width / 2, @canvas.height / 2,
          :anchor => :center, :image => @tkimg
      else
        @image[:image] = @tkimg
      end
      old_img.delete if old_img
    end

    def show_img_grid img, n
      pos = [[(@canvas.width * 1.0 / 4).to_i, (@canvas.height * 1.0 / 4).to_i],
             [(@canvas.width * 3.0 / 4).to_i, (@canvas.height * 1.0 / 4).to_i],
             [(@canvas.width * 1.0 / 4).to_i, (@canvas.height * 3.0 / 4).to_i],
             [(@canvas.width * 3.0 / 4).to_i, (@canvas.height * 3.0 / 4).to_i]]
      w, h = @canvas.width / 2, @canvas.height / 2
      data = Base64.encode64(img.resized(w * 0.99, h * 0.99))
      tkimg = TkPhotoImage.new :data => data
      tkcimg = TkcImage.new @canvas, *pos[n], :anchor => :center, :image => tkimg

      @image_grid << tkcimg << tkimg
    end

    def clear_img_grid
      @image_grid.each{|i| i.delete}
      @image_grid = []
    end

    def run
      Tk.mainloop
    end
  end
end
