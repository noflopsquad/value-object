module ValueObjects
  module ValueObject
    BUILT_IN_INVARIANTS = {
      :integers => Proc.new do |obj|
        obj.values.all? {|value| value.is_a? Integer}
      end
    }

    def fields(*names)
      raise NotDeclaredFields.new() if names.empty?()

      attr_reader(*names)

      define_method(:check_invariants) do
      end

      define_method(:initialize) do |*values|
        names.zip(values) do |name, value|
          instance_variable_set(:"@#{name}", value)
        end
        check_invariants()
      end

      define_method(:values) do
        names.map { |field| send(field) }
      end

      define_method(:eql?) do |other|
        self.class == other.class && values == other.values
      end

      define_method(:==) do |other|
        eql?(other)
      end

      define_method(:hash) do
        self.class.hash ^ values.hash
      end
    end

    def invariants(*predicate_symbols)
      define_method(:check_invariants) do
        predicate_symbols.each do |predicate_symbol|
          begin
            valid = send(predicate_symbol)
          rescue
            predicate = BUILT_IN_INVARIANTS[predicate_symbol]

            raise NotImplementedInvariant.new(predicate_symbol) unless predicate

            valid = predicate.call(self) if predicate
          end

          raise ViolatedInvariant.new(predicate_symbol, self.values) unless valid
        end
      end
    end
  end

  class NotImplementedInvariant < Exception
    def initialize(name)
      super "Invariant #{name} needs to be implemented"
    end
  end

  class ViolatedInvariant < Exception
    def initialize(name, wrong_values)
      super "Fields values " + wrong_values.to_s + " violate invariant: #{name}"
    end
  end

  class NotDeclaredFields < Exception
    def initialize()
      super "At least one field must be declared"
    end
  end
end
