require 'pi_piper'
#require 'pry'
include PiPiper

class Keyboard

  attr_accessor :letter,:button1,:led

  def initialize
    @letter = 0x0
    #@button1 = Pin.new(:pin => 02, :direction => :in, invert: true)
    @led = Pin.new(:pin => 03, :direction=> :out)
  end

  def wait_keyboard(times=nil)
    watch :pin => 02 do
      #puts "Pin 02 changed from #{last_value} to #{value}"
      if value == 1
        puts "click 1"
      end
    end

    watch :pin => 03 do
      if value ==1
        puts "click 2"
      end
    end
    wait
  end
end

key = Keyboard.new
key.wait_keyboard

#binding.pry
