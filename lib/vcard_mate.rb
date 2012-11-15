require_relative 'vcard_mate/version'
require_relative 'vcard_mate/vcard'
require_relative 'vcard_mate/property'

module VCardMate

  class << self

    def create(*args)
      VCardMate::VCard.new(*args)
    end

    def parse(*args)
      VCardMate::VCard.new.parse(*args)
    end

  end

end
