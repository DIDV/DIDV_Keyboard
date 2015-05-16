require 'daemons'

script = "#{File.dirname(__FILE__)}/keyboard_daemon.rb"
options = {
  app_name: "keyboard_daemon",
  dir_mode: :normal,
  dir: "/home/didv/pid",
  log_dir: "/home/didv/log",
  log_output: true
}

Daemons.run(script, options)
