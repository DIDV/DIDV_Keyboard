require 'pi_piper'
include PiPiper
require 'yaml'
#require 'pry'
require 'timers'
require 'eventmachine'

module DIDV

  class Keyboard < EventMachine::Connection

    attr_accessor :text_buttons, :navigation_buttons

    
    def initialize #(conf)
      super
      @letter = [0,0,0,0,0,0]
      @nav_pressed = nil
      @pinout = load_pinout "pinout.yaml" #conf
      initialize_text_buttons
      @timer = Timers::Group.new
      @response = "000000"
      initialize_timer
      wait_keyboard
    end

    #Inicia uma thread que observa os botões com função de digitação
    #@param button_object[Object] , pos[int] objeto e sua posição no array de botões de navegação
    def listen_keyboard(button_object,pos)
      puts "Escutando Botão #{button_object.pin}" #mensagem para debug
      thread = Thread.new do
        loop do
          button_object.wait_for_change
          if button_object.read == 1
            #puts "HIGH :D #{button_object.pin}" #mensagem para debug
            sleep(0.06)
            if button_object.read == 1
              #puts "Still HIGH :D #{button_object.pin}"#mensagem para debug
              #puts "#{@timer.current_offset}"#mensagem para debug
              @letter[pos-1] = 1
            end
          end
        end
      end
      thread.abort_on_exception = true
      thread
    end

    #Inicia uma thread que observa os botões referentes a navegação na interface de usuário e na navegação de texto
    #@param button_object[Object] pos[int] objeto e sua posição no array de botões de navegação
    def listen_nav_keyboard(button_object,pos)
      puts "Escutando Botão de Navegação #{button_object.pin}" #mensagem para debug
      thread = Thread.new do
        loop do
          button_object.wait_for_change
          if button_object.read == 1
            puts "HIGH :D #{button_object.pin}" #mensagem para debug
            sleep(0.06)
            if button_object.read == 1
              puts "Still HIGH :D #{button_object.pin}"#mensagem para debug
              puts "#{@timer.current_offset}"#mensagem para debug
              case pos
                when 1
                  @nav_button = 's'.chr
                when 2
                  @nav_button = 'esp'.chr
                when 3
                  @nav_button = 'e'.chr
                when 4
                  @nav_button = 'fim'.chr
                when 5
                  @nav_button = 'a'.chr
                when 6
                  @nav_button = 'v'.chr
                when 7
                  @nav_button = 'b'.chr
              end
            end
          end
        end
      end
      thread.abort_on_exception = true
      thread
    end

    #inicializa o timer que dispara o evento de enviar o dado e limpar o array
    def initialize_timer
      thread = Thread.new do
        @timer.every(0.60){send_and_clean}
        loop do
          @timer.wait
        end
      end
      thread.abort_on_exception = true
      thread
    end

    #posta o dado para o servidor eventmachine e limpa o array de dados, para que novos dados possam ser capturados
    def send_and_clean
      if(@letter.join != '000000')
        puts "#{@letter.join}"
        send_data @letter.join if @waiting
        @letter = [0,0,0,0,0,0]
      end
      if (@nav_button != nil)
        puts @nav_button
        send_data @nav_button.chr if @waiting
        @nav_button = nil
      end
    end

    #observa os botões
    def wait_keyboard
      thread = Thread.new do
        @text_buttons.each { |pos,pin| listen_keyboard(pin,pos) }
        @navigation_buttons.each {|pos,pin| listen_nav_keyboard(pin,pos) }
        wait
      end
      thread.abort_on_exception = true
      thread
    end

    #recebe dado do EventMachine
    #@param data[string]
    def receive_data(data)
      @waiting = true if data == 'waiting'
    end

    private
    #carrega arquivo de configuração com os pinos
    #@param conf[String] endereço do arquivo yaml com a configuração dos pinos
    def load_pinout conf
      YAML::load_file(conf)
    end

    #passa a escutar os botões daemon principal
    def initialize_text_buttons
      @text_buttons = {}
      @navigation_buttons = {}
      @pinout["text"].each do |pos,pin|
        @text_buttons[pos] = Pin.new(pin: pin, direction: :in, invert: true)
      end
      @pinout["navigation"].each do |pos,pin|
        @navigation_buttons[pos] = Pin.new(pin: pin, direction: :in, invert: true)
      end
    end

  end
#binding.pry
end

#executa client eventmachine que se conectará ao server no daemon principal
EventMachine.run do
  EventMachine::connect '127.0.0.1',9001,DIDV::Keyboard
end
