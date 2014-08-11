module VCardigan

  class VCard

    # A quoted-printable encoded string with a trailing '=', indicating that
    # it's not terminated
    UNTERMINATED_QUOTED_PRINTABLE = /ENCODING=QUOTED-PRINTABLE:.*=$/

    attr_accessor :version
    attr_accessor :chars

    def initialize(options = {})
      # Backwards compatibility
      if options.is_a? String
        options = { :version => options }
      end

      # Default options
      @version = options[:version] || '4.0'
      @chars = options[:chars] || 75

      @fields = {}
      @groups = {}
      @group = nil
    end

    def parse(data)
      lines = unfold(data)

      # Add the parsed properties to this vCard
      lines.each do |line|
        if line =~ /^VERSION:(.+)/
          @version = $1
          next
        end

        property = VCardigan::Property.parse(self, line)
        add_prop(property)
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

      args.reject!(&:nil?)

      # Build the property and add it to the vCard
      if args.any?
        property = build_prop(name, *args)
        add_prop(property)
      end
    end

    def remove(name)
      if @fields.has_key?(name)
        fields = @fields.delete(name)

        fields.each do |field|
          group_name = field.group
          if group_name
            group_field_names = @groups.delete(group_name).reject do |delete_field|
              delete_field == name
            end.map(&:name)

            group_field_names.each do |field_name|
              named_fields = @fields[field_name]
              if named_fields
                named_fields.delete_if {|prop| prop.group == group_name }
              end
            end
          end
        end
      end
    end

    def field(name)
      name = name.to_s.downcase
      if @group and @fields[name]
        # Finds all items that match the prop type in the group
        fields = @fields[name].find_all do |prop|
          prop.group == @group.to_s
        end

        # Reset the group to nil and return the fields
        @group = nil
        fields
      else
        @fields[name]
      end
    end

    def group(name)
      @groups[name]
    end

    def to_s
      # Raise errors if invalid
      validate

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

    def valid?
      validate
      true
    rescue VCardigan::EncodingError
      false
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

    # Split on \r\n or \n to get the lines, unfold continued lines (they
    # start with " " or \t), and return the array of unfolded lines.
    #
    # Strip away BEGIN:VCARD and END:VCARD
    #
    # This also supports the (invalid) encoding convention of allowing empty
    # lines to be inserted for readability - it does this by dropping zero-length
    # lines.
    # Borrowed from https://github.com/qoobaa/vcard
    def unfold(card)
      unfolded = []

      prior_line = nil
      card.lines do |line|
        line.chomp!
        # If it's a continuation line, add it to the last.
        # If it's an empty line, drop it from the input.
        if line =~ /^[ \t]/
          unfolded[-1] << line[1, line.size-1]
        elsif line =~ /(^BEGIN:VCARD$)|(^END:VCARD$)/
        elsif prior_line && (prior_line =~ UNTERMINATED_QUOTED_PRINTABLE)
          # Strip the trailing = off prior line, then append current line
          unfolded[-1] = prior_line[0, prior_line.length-1] + line
        elsif line =~ /^$/
        else
          unfolded << line
        end
        prior_line = unfolded[-1]
      end

      unfolded
    end

    def build_prop(name, *args)
      VCardigan::Property.create(self, name, *args)
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

    def validate
      unless @fields['fn']
        raise VCardigan::EncodingError,
          "vCards must include an FN field"
      end
    end

  end

end
