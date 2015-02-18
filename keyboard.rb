require 'pi_piper'
#require 'pry'
include PiPiper

class Keyboard

  attr_accessor :letter,:button1,:led

  def initialize
    @letter = 0x0
    @button1 = Pin.new(:pin => 02, :direction => :in, invert: true)
    @led = Pin.new(:pin => 03, :direction=> :out)
  end

  def wait_keyboard(times=nil)

      puts "Inicio"
      #unless times
      loop do
        @button1.wait_for_change
        if @button1.value == 1
          puts "HIGH :D"
        else
          puts "low :("
        end
      end
      # else
      #   times.times do
      #     @button1.wait_for_change
      #     if @button1.value == 1
      #       puts "HIGH :D"
      #     else
      #       puts "low :("
      #     end
      #   end
      # end
    puts "Fim"
  end
end

key = Keyboard.new
key.wait_keyboard

#binding.pry
