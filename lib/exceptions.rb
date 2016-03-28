module ValueObject
  class BadInvariantDefinition < Exception
    def initialize()
      super "Invariant must be either declared or specified"
    end
  end

  class NotImplementedInvariant < Exception
    def initialize(name)
      super "Invariant #{name} needs to be implemented"
    end
  end

  class ViolatedInvariant < Exception
    def initialize(name, wrong_values)
      super "Field values " + wrong_values.to_s + " violate invariant: #{name}"
    end
  end

  class NotDeclaredFields < Exception
    def initialize()
      super "At least one field must be declared"
    end
  end

  class FieldWithoutValue < Exception
    def initialize(fields)
      super "Declared fields #{fields} must have value"
    end
  end

  class WrongNumberOfArguments < Exception
    def initialize(fields_number, arguments_number)
      super "Declared #{fields_number} fields but passing #{arguments_number}"
    end
  end
end
