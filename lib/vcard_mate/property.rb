module VCardMate

  class Property

    attr_accessor :group
    attr_reader :params
    attr_reader :values

    def initialize(vcard, name, *args)
      @vcard = vcard
      @params = {}
      @values = []
      @group = nil

      # Determine whether this property name has a group
      name_parts = name.to_s.split('.', 2)

      # If it has a group, set it
      if name_parts.length > 1
        @group = name_parts.first
      end

      # Set the name
      @name = name_parts.last.downcase

      # Build out the values/params from the passed arguments
      args.each do |arg|
        if arg.is_a? Hash
          arg.each do |param, value|
            param = param.to_s.downcase
            value = value.to_s
            add_param(param, value) unless has_param?(param, value)
          end
        else
          @values.push arg.to_s
        end
      end
    end
    
    def value(idx = 0)
      @values[idx]
    end

    def param(name)
      name ? @params[name.to_s.downcase] : nil
    end

    def self.parse(vcard, data)
      # Gather the parts
      data = data.strip
      parts = data.split(':', 2)
      values = parts.last.split(';')
      params = parts.first.split(';')
      name = params.shift
      
      # Create argument array
      args = [vcard, name]

      # Add values to array
      args.concat(values)

      # Add params to array
      params.each do |param|
        keyval = param.split('=')
        hash = Hash[keyval.first, keyval.last]
        args.push(hash)
      end

      # Instantiate a new class with the argument array
      new(*args)
    end

    def to_s
      # Name/Group
      name = @name.upcase
      property = @group ? "#{@group}.#{name}" : name.upcase

      # Params
      @params.each_with_index do |(key, value), idx|
        property << ';' if idx === 0
        property << key.upcase << '=' << value
      end

      # Split with colon
      property << ':'

      # Values
      @values.each_with_index do |value, idx|
        property << ';' unless idx === 0
        property << value
      end

      return property
    end

    private

    def has_param?(name, value)
      false
    end

    def add_param(name, value)
      name = name.to_s.downcase
      value = value.to_s
      if @params[param]
        # Create array of param values if we have an existing param name
        # present in the hash
        unless @params[params].is_a? Array
          @params[param] = [@params[param]]
        end
        @params[param].push(value)
      else
        # Default is to just set the param to the value
        @params[param] = value
      end
    end

  end

end
