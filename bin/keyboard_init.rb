require 'daemons'

script = "#{File.dirname(__FILE__)}/keyboard_daemon.rb"
options = {
  app_name: "keyboard_daemon",
  log_dir: "/home/didv",
  log_output: true
}

Daemons.run(script, options)
