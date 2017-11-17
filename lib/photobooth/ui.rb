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
      @canvas.bind(:Configure){|e| @canvas.width = e.width; @canvas.height = e.height; @canvas.delete "all"}
    end

    def show_img img
      data = Base64.encode64(img.resized(@canvas.width, @canvas.height))
      tkimg = TkPhotoImage.new :data => data
      TkcImage.new @canvas, 0, 0, :anchor => :nw, :image => tkimg
    end

    def run
      Tk.mainloop
    end
  end
end
