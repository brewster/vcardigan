module VCardMate

  class VCard

    VCARD_PATTERN = /BEGIN:VCARD\s+(.*?)VERSION:(.+?)\s+(.+?)END:VCARD/m;

    attr_accessor :version

    def initialize(version = '4.0')
      @version = version
      @fields = {}
      @group = nil
    end

    def parse(data)
      match = VCARD_PATTERN.match(data)
      if match
        # Set version number
        @version = match[2]
        lines = "#{match[1]}#{match[3]}"

        # Add the parsed properties to this vCard
        lines.each_line do |line|
          property = VCardMate::Property.parse(line)
          add_prop(property)
        end
      end
      self
    end

    def [](group)
      @group = group
      self
    end

    def method_missing(method, *args)
      if args.empty?
        # Return the property/properties when no arguments are passed
        get_prop(method)
      else
        # If there's a group, add it
        if @group
          method = "#{@group}.#{method}"
        end

        # Add property to vCard
        property = VCardMate::Property.new(method, *args)
        add_prop(property)
      end
    end

    def add_prop(property)
      name = property.instance_variable_get(:@name)

      # Create a field on the fields hash, if not already present, to house
      # the property
      unless @fields.has_key? name
        @fields[name] = []
      end
      
      # Add the property to the field array
      @fields[name].push(property)
    end

    def get_prop(name)
      field = @fields[name.to_s.downcase]
      case field.length
      when 0
        nil
      when 1
        field.first
      else
        field
      end
    end

    def to_s
      # Start vCard
      vcard = VCardMate::Property.new(:begin, 'VCARD').to_s << "\n"

      # Add version
      vcard << VCardMate::Property.new(:version, @version).to_s << "\n"

      # Add the properties
      @fields.each do |field, properties|
        properties.each do |property|
          vcard << property.to_s << "\n"
        end
      end

      # END
      vcard << VCardMate::Property.new(:end, 'VCARD').to_s << "\n"

      # Return vCard
      return vcard
    end

    # Aliases ##########

    def name(*args)
      n(*args)
    end

    def fullname(*args)
      fn(*args)
    end

  end

end
