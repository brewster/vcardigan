module VCardMate

  class Property

    attr_accessor :group
    attr_reader :name
    attr_reader :params
    attr_reader :values

    def initialize(vcard, name, *args)
      @vcard = vcard
      @params = {}
      @values = []
      @group = nil

      setup if respond_to? :setup

      # Determine whether this property name has a group
      name_parts = name.to_s.split('.', 2)

      # If it has a group, set it
      if name_parts.length > 1
        @group = name_parts.first
      end

      # Set the name
      @name = name_parts.last.downcase

      # Build out the values/params from the passed arguments
      valueIdx = 0
      args.each do |arg|
        if arg.is_a? Hash
          arg.each do |param, value|
            param = param.to_s.downcase
            add_param(param, value) unless has_param?(param, value)
          end
        else
          add_value(arg.to_s, valueIdx)
          valueIdx += 1
        end
      end
    end

    def self.create(vcard, name, *args)
      name = name.to_s.downcase
      classname = ''

      case name
      when 'n'
        className = 'NameProperty'
      else
        className = 'Property'
      end

      cls = Module.const_get('VCardMate').const_get(className)
      cls.new(vcard, name, *args)
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
      self.create(*args)
    end
    
    def value(idx = 0)
      @values[idx]
    end

    def param(name)
      name ? @params[name.to_s.downcase] : nil
    end

    def to_s
      # Name/Group
      name = @name.upcase
      property = @group ? "#{@group}.#{name}" : name.upcase

      # Params
      @params.each do |param, value|
        str = param_to_s(param, value)
        property << ';' << str if str
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

    def version
      @vcard.version
    end

    def v3?
      version == '3.0'
    end

    def v4?
      version == '4.0'
    end

    def add_value(value, idx)
      @values.push(value)
    end

    def has_param?(name, value)
      false
    end

    def add_param(name, value)
      name = name.to_s.downcase
      if @params[name]
        # Create array of param values if we have an existing param name
        # present in the hash
        unless @params[name].is_a? Array
          @params[name] = [@params[name]]
        end
        @params[name].push(value)
      else
        # Default is to just set the param to the value
        @params[name] = value
      end
    end

    def param_to_s(name, value)
      case name
      when 'preferred'
        if !value or value === 0
          return nil
        end
        name = v3? ? 'type' : 'pref'
        value = v3? ? 'pref' : value.is_a?(Numeric) ? value.to_s : '1'
      else
      end
      name.upcase << '=' << value
    end

  end

end
