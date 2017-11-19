require 'photobooth/ui'
require 'photobooth/image'
require 'photobooth/camera'
require 'thread'

class Photobooth
  COUNTDOWN = 5
  COUNTDOWN_SHORT = 1

  def initialize
    Thread.abort_on_exception
    cams = Camera.find
    p cams
    @camera = cams[0]

    @uilock = Mutex.new
    @ui = UI.new

    @ui.register_onclick {btn_press}
    @ignore_btn = false

    mainloop
    @ui.run
  end

  def btn_press
    if not @ignore_btn
      @ignore_btn = true
      Thread.new {take_imges}.abort_on_exception = true
    end
  end

  def take_imges
    images = []
    images << take_img(COUNTDOWN)
    @ui.show_img_grid images[0], 0
    3.times do |i|
      images << take_img(COUNTDOWN_SHORT)
      @uilock.synchronize do
        @ui.show_img_grid images[-1], i + 1
      end
    end
    @ui.clear_text
    images.each do |img|
      img.save
    end
    sleep 2
    @ui.clear_img_grid
    @ignore_btn = false
  end

  def take_img cntdn
    cntdn.times do |i|
      @ui.display_text (cntdn - i)
      sleep 1
    end
    @ui.display_text "0"
    @uilock.synchronize do
      @ui.flash
      @camera.capture
    end
  end

  def mainloop
    x = Thread.new do
      loop do
        sleep 1/30.0
        @uilock.synchronize do
          img = @camera.capture_preview
          @ui.show_img img
        end
      end
    end.abort_on_exception = true
  end
end
