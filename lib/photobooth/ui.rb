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
      @canvas = TkCanvas.new @root
      @canvas.pack :fill => "both", :expand => "yes"
      @canvas.bind(:Configure){|e| @canvas.width = e.width; @canvas.height = e.height}
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
      @text = TkcText.new @canvas, 0, 0,
        :anchor => :nw,
        :text => txt,
        :font => ["Sans", 25]
      @text.raise
    end

    def clear_text
      @text.delete
      @text = nil
    end

    def flash
      white = TkcRectangle.new @canvas, 0, 0, @canvas.width, @canvas.height, :fill => "White"
      white.raise
      sleep 0.1
      white.delete
    end

    def show_img img
      data = Base64.encode64(img.resized(@canvas.width, @canvas.height))
      tkimg = TkPhotoImage.new :data => data
      if @image.nil?
        @image = TkcImage.new @canvas, 0, 0, :anchor => :nw, :image => tkimg
      else
        @image[:image] = tkimg
      end
    end

    def show_img_grid img, n
      pos = [[0, 0], [@canvas.width / 2, 0], [0, @canvas.height / 2], [@canvas.width / 2, @canvas.height / 2]]
      w, h = @canvas.width / 2, @canvas.height / 2
      data = Base64.encode64(img.resized(w, h))
      tkimg = TkPhotoImage.new :data => data
      tkcimg = TkcImage.new @canvas, *pos[n], :anchor => :nw, :image => tkimg

      @image_grid << tkcimg
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
