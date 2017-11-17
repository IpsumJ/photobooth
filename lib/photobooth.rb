require 'photobooth/ui'
require 'photobooth/image'
require 'photobooth/camera'

class Photobooth
  def initialize
    cams = Camera.find
    p cams
    @camera = cams[0]
    @ui = UI.new
    mainloop
    @ui.run
  end

  def mainloop
    x = Thread.new do
      loop do
        sleep 0.2
        img = @camera.capture_preview
        @ui.show_img img
      end
    end
    x.abort_on_exception = true
  end
end
