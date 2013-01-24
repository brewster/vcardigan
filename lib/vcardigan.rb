require_relative 'vcardigan/version'
require_relative 'vcardigan/vcard'
require_relative 'vcardigan/property'
require_relative 'vcardigan/properties/name_property'
require_relative 'vcardigan/errors'

module VCardigan

  class << self

    def create(*args)
      VCardigan::VCard.new(*args)
    end

    def parse(*args)
      VCardigan::VCard.new.parse(*args)
    end

  end

end
