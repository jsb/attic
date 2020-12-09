#!/usr/bin/ruby

require 'jsb/irc'
require 'jsb/util'
require 'transform'

def generate_name
  nicklist = File.readlines('nicks.txt').map {|n| n.gsub(/[+%@!*&]+/, '').strip }
  nicklist.sort! {-1 + rand(3)}
  nick_part1 = nicklist[0]
  nick_part2 = nicklist[1]
  ratio = 0.2 + rand*0.6
  nick_part1[0..(((nick_part1.length-1) * ratio).ceil)] + nick_part2[(((nick_part2.length-1) * (1-ratio)).floor)..((nick_part2.length-1))]
end

def select_name
  puts "Type y to choose a nick, hit Enter to generate another one"
  begin
    nick = generate_name
    print "Nick: #{nick} "
  end until gets.strip.downcase == 'y'
  puts "Nick chosen: #{nick}"
  nick
end

class MirrorBot < Client
  def initialize()
    nick = select_name
    super('irc.icq.com', 6667, nick, nick.gsub(/\W+/, '').downcase)
    @nicklist = []
    @blacklist = File.readlines('blacklist.txt').map {|line| line.strip}.compact
    @last_action = Time.now
    
    File.open('partner_log.txt', 'w').close
    File.open('tutor_log.txt', 'w').close
    
    puts "Connecting ..."
  end
  
  def update_nicklist
    begin
      # only update if nicks.txt hasnt been modified for 60 secs
      return if File.mtime('nicks.txt') > Time.now - 60
      
      nicklist = File.readlines('nicks.txt').map {|n| n.strip }
      newlist = (@nicklist + nicklist).map {|n| n.gsub(/[+%@!*&]+/, '').strip }.uniq.sort - [@nick, ""]
      newlist.reject! {|nick| nick =~ /^Guest/ }
      newlist.reject! {|nick| nick =~ /^\d{3,}/ }
      File.open('nicks.txt', 'w') do |f|
        f.puts newlist
      end
    rescue Errno::EACCES, Errno::ENOENT
      # Don't care. File will probably be availible next time the nicklist is updated.
    end
  end
  
  def event_375(user, *args)
    puts "Connected to #{@server_name}."
    send_line "JOIN #teens_german"
  end
  
  def event_353(user, nick, separator, channel, nicklist)
    @nicklist += nicklist.split(' ')#.collect {|item| item.gsub(/^[+%@!*]/i, '') }.compact
  end
  
  def event_366(user, *args)
    update_nicklist
    
    p @nicklist
    print "\n\n"
  end
  
  def greet_partner
    greetings = File.readlines('pickup_lines.txt').map {|q| q.strip }
    greet1 = greetings.sample
    greet2 = greetings.sample
    
    say(@partner, greet1)
    log_to_file('partner_log.txt', "<#{@nick}> #{greet1}")
    
    say(@tutor, greet2)
    log_to_file('tutor_log.txt', "<#{@nick}> #{greet2}")
  end
  
  def event_privmsg(user, target, message="")
    if(user =~ /(.+)!(.+)@(.+)/)
      nick = $1
      realname = $2
      host = $3
    end
    
    if not @partner
      # partner suchen
      if(@nicklist.include?(nick) and nick != @tutor and not @blacklist.include?(nick) and not message.include?('http://'))
        @partner = nick
        # partner gefunden! :D
        puts "Partner found: #{@partner} (\"#{message}\")"
        @last_action = Time.now
      end
    end
    if not @tutor
      # lehrer suchen
      if(@nicklist.include?(nick) and nick != @partner and not @blacklist.include?(nick) and not message.include?('http://'))
        @tutor = nick
        # lehrer gefunden! :D
        puts "Tutor found: #{@tutor} (\"#{message}\")"
        @last_action = Time.now
        
        # fertig!
        sleep 5 + rand*5
        greet_partner
      end
    end
    
    # log questions to use for engaging conversations
    if target == @nick and (nick == @partner or nick == @tutor)
      if message =~ /\?\s*$/ and not (message.include?(@nick) or message.include?(@partner) or message.include?(@tutor))
        questions = File.readlines('questions.txt').map {|q| q.strip }
        questions = (questions + [message.strip]).uniq.sort
        File.open('questions.txt', 'w') do |f|
          f.puts questions
        end
      end
    end
    
    # log private queries from unknown sources to collect pickup lines
    if target == @nick and not (nick == @partner or nick == @tutor)
      pickup_lines = File.readlines('pickup_lines.txt').map {|q| q.strip }
      pickup_lines = (pickup_lines + [message.strip]).uniq.sort
      File.open('pickup_lines.txt', 'w') do |f|
        f.puts pickup_lines
      end
    end
    
    if(@partner and @tutor)
      if(target == @nick and nick == @partner)
        puts "<#{nick} -> #{@nick}> #{message}"
        
        log_to_file('partner_log.txt', "<#{nick}> #{message}")
        
        # replace nicks accordingly
        message.gsub!(/#{Regexp.escape(@nick)}|#{Regexp.escape(@partner)}/i) do |match|
          if match.downcase == @partner.downcase
            @nick
          else
            @tutor
          end
        end
        
        trans_message = transform(message)
        message = trans_message if(message.squeeze.length > 4 and trans_message.squeeze.length > 4)
        say(@tutor, message)
        
        log_to_file('tutor_log.txt', "<#{@nick}> #{message}")
      end
      
      if(target == @nick and nick == @tutor)
        puts "<#{nick} -> #{@nick}> #{message}"
        
        log_to_file('tutor_log.txt', "<#{nick}> #{message}")
        
        # replace nicks accordingly
        message.gsub!(/#{Regexp.escape(@nick)}|#{Regexp.escape(@tutor)}/i) do |match|
          if match.downcase == @tutor.downcase
            @nick
          else
            @partner
          end
        end
        
        trans_message = transform(message)
        message = trans_message if(message.squeeze.length > 4 and trans_message.squeeze.length > 4)
        say(@partner, message)
        
        log_to_file('partner_log.txt', "<#{@nick}> #{message}")
      end
    end
  end
  
  def event_nick(user, newnick)
    if(user =~ /(.+)!(.+)@(.+)/)
      nick = $1
      realname = $2
      host = $3
      
      if(nick == @partner)
        @partner = newnick
        puts "* #{nick} renamed to #{newnick}"
      end
      if(nick == @tutor)
        @tutor = newnick
        puts "* #{nick} renamed to #{newnick}"
      end
    end
  end
  
  def event_join(user, channel)
    if(user =~ /(.+)!(.+)@(.+)/)
      nick = $1
      realname = $2
      host = $3
      
      @nicklist << nick
      @nicklist.uniq!
      update_nicklist
    end
  end
  
  def event_quit(user, quitmsg)
    if(user =~ /(.+)!(.+)@(.+)/)
      nick = $1
      realname = $2
      host = $3
      
      if(nick == @partner)
        @partner = nil
        puts "* #{nick} has quit (#{quitmsg})"
      end
      if(nick == @tutor)
        @tutor = nil
        puts "* #{nick} has quit (#{quitmsg})"
      end
    end
  end
  
  def say(target, line)
    puts "<#{@nick} -> #{target}> #{line}"
    send_line "PRIVMSG #{target} :#{line}"
    @last_action = Time.now
  end
  
  def log_to_file(filename, line)
    begin
      File.open(filename, 'a') do |f|
        f.puts line
      end
    rescue Errno::EACCES
      sleep 1
      retry
    end
  end
  
  def heartbeat
    idle_time = (Time.now - @last_action).ceil
    puts "... idle for #{idle_time} seconds"
    if @partner and @tutor
      if idle_time > (80 + rand(40))
        @last_action = Time.now
        
        if rand(3).zero? # sometimes, just drop one of the partners ...
          if rand(2).zero?
            puts "* Dropped #{@partner} for being idle"
            @partner = nil
          else
            puts "* Dropped #{@tutor} for being idle"
            @tutor = nil
          end
        else # ... or try to provoke a response
          line = File.readlines('questions.txt').map {|q| q.strip }.sample
          if rand(2).zero?
            say(@tutor, line)
            File.open('tutor_log.txt', 'a') do |f|
              f.puts "<#{@nick}> #{line}"
            end
          else
            say(@partner, line)
            File.open('partner_log.txt', 'a') do |f|
              f.puts "<#{@nick}> #{line}"
            end
          end
        end
      end
    end
  end
end

bot = MirrorBot.new
session = bot.connect
heartbeat = Thread.new(bot) do |b|
  loop do
    sleep 50 + rand*30
    b.heartbeat
  end
end
session.join
