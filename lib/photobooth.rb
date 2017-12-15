require 'photobooth/ui'
require 'photobooth/image'
require 'photobooth/camera'
require 'photobooth/config'
require 'photobooth/serial'
require 'thread'

class Photobooth
  def initialize
    Thread.abort_on_exception
    if Config[:auto_camera]
      cams = Camera.find false
      if cams.size > Config[:auto_camera].to_i
        @camera = cams[Config[:auto_camera].to_i]
      else
        puts "camera not found"
        exit
      end
    else
      cams = Camera.find true
      cams.each_with_index do |c, i|
        puts "%i %s" % [i, c.model]
      end
      print "Choose camera: "
      i = gets.to_i
      @camera = cams[i]
    end

    if Config[:serial_port]
      serial = Seril.new Config[:serial_port]
      serial.register_onclick self
    end

    @ui = UI.new self
    @running = true
    @no_preview = false

    @ui.register_onclick {|e| btn_press e}
    @ignore_btn = false

    mainloop
    @ui.run
  end

  def btn_press btn = :btn0
    if not @ignore_btn
      @ignore_btn = true
      Thread.new do
        case btn
        when :btn0
          take_imges
        when :btn1
          take_image_and_twitter
        end
        @ignore_btn = false
      end
    end
  end

  def take_image_and_twitter
    Config[:countdown].to_i.times do |i|
      @ui.display_text (Config[:countdown].to_i - i)
      sleep 1
    end
    @ui.display_text "0"
    @no_preview = true
    image = take_img
    @ui.clear_text
    @ui.show_img image
    text = Config[:twitter_text][rand Config[:twitter_text].size]
    image.save_and_mark_to_tweet text
    sleep Config[:review_time]
    @no_preview = false
  end

  def take_imges
    images = []
    Config[:countdown].to_i.times do |i|
      @ui.display_text (Config[:countdown].to_i - i)
      sleep 1
    end
    @ui.display_text "0"
    images << take_img
    @ui.clear_text
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
        unless @no_preview
          img = @camera.capture_preview
          @ui.show_img img
        end
        t_last_frame = Time.now
      end
    end
    @main_thread.abort_on_exception = true
  end
end
