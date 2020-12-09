require 'socket'
require 'iconv'

def try_to_convert(string, from, to)
  begin
    string = Iconv.iconv(to, from, string).to_s
    return string
  rescue Iconv::IllegalSequence, Iconv::InvalidCharacter
    return string
  end
end

class IRCLineFormatError < StandardError; end

class Client
  ServerUsesUTF8 = false
  
  def initialize(server_name, server_port, nick, realname=nick)
    @server_name = server_name
    @server_port = server_port
    @server_socket = nil
    @server_connected = false
    
    @nick = nick
    @realname = realname
  end
  
  def connect()
    if(@server_socket = TCPSocket.new(@server_name, @server_port))
      @server_connected = true
      log_on
      Thread.new(self) {|target| target.main_loop }
    else
      @server_connected = false
    end
  end
  
  def main_loop()
    loop do
      break unless @server_connected
      if(raw_line = get_line)
        parse_line(raw_line)
      end
    end
  end
  
  def log_on
    send_line "NICK #{@nick}"
    send_line "USER #{@realname} localhost localhost #{@realname}"
  end
  
  def get_line
    if @server_connected
      result = @server_socket.gets
      if(result)
        result = try_to_convert(result, 'utf-8', 'ascii') if ServerUsesUTF8
        return result.chomp
      end
    else
      nil
    end
  end
  
  def send_line(line)
    if @server_connected
      line = try_to_convert(line, 'ascii', 'utf-8') if ServerUsesUTF8
      @server_socket.puts(line.chomp)
    else
      nil
    end
  end
  
  def parse_line(line)
    if(line =~ /^(:(\S+) )?([A-Z0-9]+)( (.+))?$/)
      user = $2
      command = $3
      parameters = $5
      
      temp_array = parameters.split(/:/)
      parameter_array = temp_array[0].split(/ +/)
      parameter_array << temp_array[1..-1].join(':') if(temp_array[1..-1].size > 0)
      
      method_name = 'event_'+command.downcase
      if(self.methods.include?(method_name))
        event = self.method(method_name)
        event.call(user, *parameter_array)
      else
        any_event(command, user, *parameter_array)
      end
    else
      raise IRCLineFormatError, "Line format invalid."
    end
  end
  
  def event_ping(user, *params)
    send_line("PONG #{params}")
  end
  
  def any_event(command, user, *params)
    # Does nothing.
    # You may overload this to catch commands you dont want to treat in any special way.
  end
end
