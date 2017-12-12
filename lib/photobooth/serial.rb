require 'serialport'

class Photobooth
  class Seril
    BUTTONS = {:cts => :btn1, :dsr => :btn0}

    def initialize port
      @port = SerialPort.new port
      @clicks = []
      @onclick = []
      @port.rts = 0
      @port.dtr = 1
      run
    end

    def register_onclick callback
      @onclick << callback
    end

    def run
      Thread.new do
        loop do
          if @port.cts == 1
            @clicks << :cts
          end
          if @port.dsr == 1
            @clicks << :dsr
          end
          sleep 0.001
        end
      end.abort_on_exception = true
      Thread.new do
        loop do
          @clicks.uniq!
          if e = @clicks.pop
            @onclick.each do |cb|
              cb.btn_press BUTTONS[e]
            end
          end
          sleep 0.01
        end
      end.abort_on_exception = true
    end
    private :run
  end
end
