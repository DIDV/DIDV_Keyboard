require 'pi_piper'
include PiPiper
#require 'pry'
#require 'eventmachine'

class Keyboard

  attr_accessor :letter,:button1,:button2,:button3,:led,:timer

  def initialize
    @letter = 0x0
    @button1 = Pin.new(:pin => 02, :direction => :in, invert: true)
    @button2 = Pin.new(:pin => 03, :direction => :in, invert: true)
    @button3 = Pin.new(:pin => 04, :direction => :in, invert: true)
    #@timer = Timers::Group.new
    #@led = Pin.new(:pin => 0, :direction=> :out)
  end

  def listen_keyboard(button_object)
    puts "Escutando Botão #{button_object.pin}"
    thread = Thread.new do
      loop do
        button_object.wait_for_change
        if button_object.read == 1
          puts "HIGH :D #{button_object.pin}"
          sleep(1)
          if button_object.read == 1
            puts "Still HIGH :D #{button_object.pin}"
          end
        end
      end
    end
    thread.abort_on_exception = true
    thread
  end

  def wait_keyboard
    listen_keyboard(@button1)
    listen_keyboard(@button2)
    listen_keyboard(@button3)
    wait
  end

end
key = Keyboard.new
key.wait_keyboard

#binding.pry
