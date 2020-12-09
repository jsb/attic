module Translate
  module Language
    ARABIC = 'ar'
    CHINESE = 'zh'
    CHINESE_SIMPLIFIED = 'zh-CN'
    CHINESE_TRADITIONAL = 'zh-TW'
    DUTCH = 'nl'
    ENGLISH = 'en'
    FRENCH = 'fr'
    GERMAN = 'de'
    GREEK = 'el'
    ITALIAN = 'it'
    JAPANESE = 'ja'
    KOREAN = 'ko'
    PORTUGUESE = 'pt'
    RUSSIAN = 'ru'
    SPANISH = 'es'
    SWEDISH = 'sv'
    
    AVAILABLE = [ARABIC, CHINESE, CHINESE_SIMPLIFIED, CHINESE_TRADITIONAL, DUTCH, ENGLISH, FRENCH, GERMAN, GREEK, ITALIAN, JAPANESE, KOREAN, PORTUGUESE, RUSSIAN, SPANISH, SWEDISH]
    
    AVAILABLE_PAIR = AVAILABLE.map {|from| AVAILABLE.map {|to| "#{from}|#{to}" if from != to } }.flatten.compact
  end
end
