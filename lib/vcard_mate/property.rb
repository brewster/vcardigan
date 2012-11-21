module VCardMate

  class Property

    APPLE_LABEL = /_\$!<(.*?)>!\$_/

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
            param = param_name(param.to_s.downcase, value)
            value = param_value(param, value)
            add_param(param, value)
          end
        else
          value = parse_value(arg.to_s)
          add_value(value, valueIdx)
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

    def param_name(name, value)
      case name
      when 'type'
        if value == 'pref'
          name = 'preferred'
        end
      when 'pref'
        name = 'preferred'
      end
      name
    end

    def param_value(name, value)
      case name
      when 'preferred'
        number = value.to_i
        if number > 0
          value = number
        else 
          value = nil if value.downcase == 'false' or value == '0'
          value = 1 if value
        end
      end
      value
    end

    def parse_value(value)
      # Parse Apple labels
      match = value.match(APPLE_LABEL)
      if match
        value = match[1]
      end
      value
    end

    def add_value(value, idx)
      @values.push(value)
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
        value = v3? ? 'pref' : value.is_a?(Numeric) ? value : 1
      else
      end
      value = value.to_s
      name.upcase << '=' << value unless value.empty?
    end

  end

end
