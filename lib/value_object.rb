require 'exceptions'

module ValueObject
  def fields(*names)
    raise NotDeclaredFields.new() if names.empty?()

    attr_reader(*names)

    define_method(:check_invariants) do
    end
    private(:check_invariants)

    define_method(:check_fields_are_initialized) do |values|
      fields_number = names.length
      arguments_number = values.length

      raise WrongNumberOfArguments.new(fields_number, arguments_number) unless fields_number == arguments_number

      uninitialized_fields = names.zip(values).select { |name, value| value.nil? }
      uninitialized_fields_names = uninitialized_fields.map { |field| field.first }
      
      raise FieldWithoutValue.new(uninitialized_fields_names) unless uninitialized_fields.empty?
    end
    private(:check_fields_are_initialized)

    define_method(:set_instance_variables) do |values|
      names.zip(values) do |name, value|
        instance_variable_set(:"@#{name}", value)
      end
    end
    private(:set_instance_variables)

    define_method(:initialize) do |*values|
      check_fields_are_initialized(values)
      set_instance_variables(values)
      check_invariants()
    end

    define_method(:values) do
      names.map { |field| send(field) }
    end
    protected(:values)

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
        valid = invariant_holds?(predicate_symbol)
        raise ViolatedInvariant.new(predicate_symbol, self.values) unless valid
      end
    end

    define_method(:invariant_holds?) do |predicate_symbol|
      begin
        valid = send(predicate_symbol)
      rescue
        raise NotImplementedInvariant.new(predicate_symbol)
      end
    end
    private(:invariant_holds?)
  end
end
