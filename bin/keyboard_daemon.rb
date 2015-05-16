require_relative '../lib/keyboard.rb'

# Executa client eventmachine que se conectará ao server no daemon principal
#
EventMachine.run do
  EventMachine::connect '127.0.0.1',9001,DIDV::Keyboard
end
