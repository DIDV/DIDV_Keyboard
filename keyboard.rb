require 'pi_piper'
#require 'pry'
include PiPiper
#require 'eventmachine'

class Keyboard

  attr_accessor :letter,:button1, :button2,:led

  def initialize
    @letter = 0x0
    @button1 = Pin.new(:pin => 02, :direction => :in, invert: true)
    @button2 = Pin.new(:pin => 03, :direction => :in, invert: true)
    #@led = Pin.new(:pin => 0, :direction=> :out)
  end

  def listen_keyboard(button_object)
    puts 'Inicializando Botão'
    thread = Thread.new do
      loop do
        button_object.wait_for_change
          if button_object.value == 1
            puts "HIGH :D #{button_object.pin}"
          end
      end
    end
    thread.abort_on_exception = true
    thread
  end

  def wait_keyboard
    listen_keyboard(@button1)
    listen_keyboard(@button2)
    wait
  end

end
key = Keyboard.new
key.wait_keyboard

#binding.pry
