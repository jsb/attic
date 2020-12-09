require 'rsay'
require 'iconv'

def try_to_convert(string, from, to)
  begin
    string = Iconv.iconv(to, from, string).to_s
    return string
  rescue Iconv::IllegalSequence, Iconv::InvalidCharacter
    return string
  end
end

class Array
  def choose
    self[rand(size)]
  end
end

TranslationChains = [
  [Language::GERMAN, Language::ENGLISH, Language::GERMAN],
  [Language::GERMAN, Language::FRENCH, Language::GERMAN],
  [Language::GERMAN, Language::DUTCH, Language::GERMAN],
  [Language::GERMAN, Language::SWEDISH, Language::GERMAN],
  [Language::GERMAN, Language::RUSSIAN, Language::GERMAN],
  [Language::GERMAN, Language::ITALIAN, Language::GERMAN],
]

def transform(text)
  # swap gender :D
  text.gsub!(/\b(m..?nnlich|weiblich)\b/i) do |word|
    case word
      when /m..?nnlich/i then 'weiblich'
      when /weiblich/i then 'maennlich'
    end
  end
  text.gsub!(/\b(junge|m..?dchen)\b/i) do |word|
    case word
      when /junge/i then 'maedchen'
      when /m..?dchen/i then 'junge'
    end
  end
  text.gsub!(/\b(jungs|m..?dels)\b/i) do |word|
    case word
      when /jungs/i then 'maedels'
      when /m..?dels/i then 'jungs'
    end
  end
  text.gsub!(/\b(boy|girl)\b/i) do |word|
    case word
      when /boy/i then 'girl'
      when /girl/i then 'boy'
    end
  end
  text.gsub!(/\b(boys|girls)\b/i) do |word|
    case word
      when /boys/i then 'girls'
      when /girls/i then 'boys'
    end
  end
  text.gsub!(/(n mann|ne frau)\b/i) do |word|
    case word
      when /n mann/i then 'ne frau'
      when /ne frau/i then 'n mann'
    end
  end
  text.gsub!(/(n freund|ne freundin)\b/i) do |word|
    case word
      when /n freund/i then 'ne freundin'
      when /ne freundin/i then 'n freund'
    end
  end
  text.gsub!(/\b[mwMW]\b/) do |gender|
    case gender
      when 'm' then 'w'
      when 'w' then 'm'
      when 'W' then 'M'
      when 'M' then 'W'
    end
  end
  
  case rand
    when (0.0...0.1) then
      text
      
    when (0.1...0.4) then
      text.tr('FfKk', 'KkFf')
      
    when (0.4...1.0) then
      translations = TranslationChains.choose
      until translations.length < 2
        text ||= Translate.t(text, translations[0], translations[1])
        translations.shift
      end
      try_to_convert(text, 'utf-8', 'ascii')
  end
end

if __FILE__ == $0
  5.times do
    text = "Da gibt es Dinge, die nicht mehr funktionieren können: Kaputte Kruzifixe aus Kunstharz!"
    puts transform(text)
  end
end
