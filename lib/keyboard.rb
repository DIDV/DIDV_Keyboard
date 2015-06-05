require 'pi_piper'
include PiPiper
require 'yaml'
require 'timers'
require 'eventmachine'

module DIDV

  class Keyboard < EventMachine::Connection

    attr_accessor :text_buttons, :navigation_buttons


    def initialize
      super
      @letter = "000000"
      load_pinout("#{File.dirname(__FILE__)}/pinout.yaml")
      initialize_buttons
      initialize_timer
      wait_keyboard
    end

    # Inicia uma thread que observa os botões com função de digitação
    #
    # @param button_object[Pin] pino do botão
    # @param pos[int] posição do botão no array de botões de navegação
    def listen_keyboard(button_object,pos)
      puts "Escutando Botão #{button_object.pin}" # mensagem para debug
      thread = Thread.new do
        loop do
          button_object.wait_for_change
          @letter[pos-1] = '1' if check_button_state(button_object)
        end
      end
      thread.abort_on_exception = true
      thread
    end

    # Debouncer
    #
    # @param button[Pin] botão que será checado
    def check_button_state(button)
      if button.read == 1
        sleep(0.06)
        if button.read == 1
          return true
        end
      end
      false
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

              @nav_button = case pos
              when 1 then 's'
              when 2 then '000000'
              when 3 then 'e'
              when 4 then 'f'
              when 5 then 'a'
              when 6 then 'v'
              when 7 then 'b'
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
      @timer = Timers::Group.new
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

      if @letter != '000000'
        p @letter
        send_data @letter if @waiting
        @letter = '000000'
      end

      if @nav_button
        puts @nav_button
        send_data @nav_button if @waiting
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

    def receive_data(data)
      @waiting = ( data == 'waiting' )
    end

    # Carrega arquivo de configuração com os pinos
    #
    # @param conf[String] endereço do arquivo yaml com a configuração dos pinos
    def load_pinout conf
      @pinout = YAML::load_file(conf)
    end

    # Inicializa os botões
    def initialize_buttons
      @text_buttons = {}
      @navigation_buttons = {}
      @pinout["text"].each { |pos,info| @text_buttons[pos] = Pin.new(pin: info['gpio'], direction: :in, invert: info['invert']) }
      @pinout["navigation"].each { |pos,info| @navigation_buttons[pos] = Pin.new(pin: info['gpio'], direction: :in, invert: info['invert']) }
    end

    def unbind
      EM.stop
    end

  end
end
