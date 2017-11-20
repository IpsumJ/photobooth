require 'photobooth/ui'
require 'photobooth/image'
require 'photobooth/camera'
require 'photobooth/config'
require 'thread'

class Photobooth
  def initialize
    Thread.abort_on_exception
    cams = Camera.find
    if Config[:auto_camera]
      @camera = cams[Config[:auto_camera].to_i]
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
    Config[:countdown].to_i.times do |i|
      @ui.display_text (Config[:countdown].to_i - i)
      sleep 1
    end
    @ui.clear_text
    images << take_img
    @ui.show_img_grid images[0], 0
    3.times do |i|
      sleep Config[:image_delay].to_f
      images << take_img
      @uilock.synchronize do
        @ui.show_img_grid images[-1], i + 1
      end
    end
    images.each do |img|
      img.save
    end
    sleep Config[:review_time]
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
        sleep 1 / Config[:preview_fps].to_f
        @uilock.synchronize do
          img = @camera.capture_preview
          @ui.show_img img
        end
      end
    end.abort_on_exception = true
  end
end
