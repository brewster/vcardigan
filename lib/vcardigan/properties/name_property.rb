module VCardigan

  class NameProperty < Property

    def setup
      @values = ['', '', '', '', '']
    end

    private

    def add_value(value, idx)
      @values[idx] = value if value
    end

  end

end
