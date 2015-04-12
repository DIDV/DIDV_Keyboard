require 'pi_piper'
include PiPiper
require 'yaml'
#require 'pry'
require 'timers'

module DIDV

  class Keyboard

    attr_accessor :buttons

    def initialize(conf)
      @letter = [0,0,0,0,0,0]
      @pinout = load_pinout conf
      initialize_buttons
      @timer = Timers::Group.new
      #@led = Pin.new(:pin => 0, :direction=> :out)
    end

    def listen_keyboard(button_object,pos)
      puts "Escutando Botão #{button_object.pin}" #mensagem para debug
      thread = Thread.new do
        loop do
          button_object.wait_for_change
          if button_object.read == 1
            puts "HIGH :D #{button_object.pin}" #mensagem para debug
            sleep(0.06)
            if button_object.read == 1
              puts "Still HIGH :D #{button_object.pin}"#mensagem para debug
              puts "#{@timer.current_offset}"#mensagem para debug
              @letter[pos-1] = 1
            end
          end
        end
      end
      thread.abort_on_exception = true
      thread
    end

    def initialize_timer
      thread = Thread.new do
        @timer.every(0.50){send_and_clean}
        loop do
          @timer.wait
        end
      end
      thread.abort_on_exception = true
      thread
    end

    def send_and_clean
      if(@letter.join != '000000')
        puts "#{@letter.join}"
        @letter = [0,0,0,0,0,0]
      end
    end

    def wait_keyboard
      @buttons.each { |pos,pin| listen_keyboard(pin,pos) }
      wait
    end

    private

    def load_pinout conf
      YAML::load_file(conf)
    end

    def initialize_buttons
      @buttons = {}
      @pinout["buttons"].each do |pos,pin|
        @buttons[pos] = Pin.new(pin: pin, direction: :in, invert: true)
      end
    end

  end


  key = Keyboard.new('pinout.yaml')
  key.initialize_timer
  key.wait_keyboard

#binding.pry
end
