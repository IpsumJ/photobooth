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

    @ui = UI.new self
    @running = true

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
      @ui.show_img_grid images[-1], i + 1
    end
    images.each do |img|
      img.save
    end
    sleep Config[:review_time]
    @ui.clear_img_grid
    @ignore_btn = false
  end

  def take_img
    @ui.flash
    @camera.capture
  end

  def quit
    @running = false
    @main_thread.join if @main_thread
  end

  def mainloop
    @main_thread = Thread.new do
      time_frame = 1.0 / Config[:preview_fps]
      t_last_frame = Time.now
      while @running
        delay = time_frame - (Time.now - t_last_frame)
        sleep delay if delay > 0
        img = @camera.capture_preview
        @ui.show_img img
      end
    end
    @main_thread.abort_on_exception = true
  end
end
