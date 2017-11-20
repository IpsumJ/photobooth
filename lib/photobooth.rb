require 'photobooth/ui'
require 'photobooth/image'
require 'photobooth/camera'
require 'thread'

class Photobooth
  COUNTDOWN = 5
  COUNTDOWN_SHORT = 0.7

  def initialize args
    Thread.abort_on_exception
    cams = Camera.find
    if args[0] == "--first"
      @camera = cams[0]
    else
      cams.each_with_index do |c, i|
        puts "%i %s" % [i, c.model]
      end
      print "Choose camera: "
      i = gets.to_i
      @camera = cams[i]
    end

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
    COUNTDOWN.times do |i|
      @ui.display_text (COUNTDOWN - i)
      sleep 1
    end
    @ui.clear_text
    images << take_img
    @ui.show_img_grid images[0], 0
    3.times do |i|
      sleep COUNTDOWN_SHORT
      images << take_img
      @uilock.synchronize do
        @ui.show_img_grid images[-1], i + 1
      end
    end
    images.each do |img|
      img.save
    end
    sleep 2
    @ui.clear_img_grid
    @ignore_btn = false
  end

  def take_img
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
