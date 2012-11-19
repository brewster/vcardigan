module VCardMate

  class VCard

    VCARD_PATTERN = /BEGIN:VCARD\s+(.*?)VERSION:(.+?)\s+(.+?)END:VCARD/m;

    attr_accessor :version

    def initialize(version = '4.0')
      @version = version
      @fields = {}
      @groups = {}
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
          property = VCardMate::Property.parse(self, line)
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
        # Return the field property/properties when no arguments are passed
        field(method)
      else
        # Add property to vCard
        add(method, *args)
      end
    end

    def add(name, *args)
      if @group
        # If there's a group, add it to the name
        name = "#{@group}.#{name}"
        
        # Reset group to nil
        @group = nil
      end

      # Build the property and add it to the vCard
      property = build_prop(name, *args)
      add_prop(property)
    end

    def field(name)
      field = @fields[name.to_s.downcase]
      if field and field.length === 1
        return field.first
      end
      field
    end

    def group(name)
      @groups[name]
    end

    def to_s
      # Start vCard
      vcard = build_prop(:begin, 'VCARD').to_s << "\n"

      # Add version
      vcard << build_prop(:version, @version).to_s << "\n"

      # Add the properties
      @fields.each do |field, properties|
        properties.each do |property|
          vcard << property.to_s << "\n"
        end
      end

      # END
      vcard << build_prop(:end, 'VCARD').to_s << "\n"

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

    # Private ##########
    private

    def build_prop(name, *args)
      VCardMate::Property.new(self, name, *args)
    end

    def add_prop(property)
      name = property.name
      group = property.group

      # Create a field on the fields hash, if not already present, to house
      # the property
      unless @fields.has_key? name
        @fields[name] = []
      end
      
      # Add the property to the field array
      @fields[name].push(property)

      if group
        # Add a field on the groups hash, if not already present, to house the
        # group properties
        unless @groups.has_key? group
          @groups[group] = []
        end

        # Add the property to the groups array
        @groups[group].push(property)
      end
    end

  end

end
