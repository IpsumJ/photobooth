require 'photobooth/ui'
require 'photobooth/image'

class Photobooth
  def initialize
    @ui = UI.new
    mainloop
    @ui.run
  end

  def mainloop
    x = Thread.new do
      loop do
        sleep 0.2
        img = Photobooth::Image.new(File.read 'preview.jpg')
        @ui.show_img img
      end
    end
    x.abort_on_exception = true
  end
end
