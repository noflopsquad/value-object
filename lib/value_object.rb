require 'exceptions'

module ValueObject

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(*values)
    @values = values
    check_fields_are_initialized
    set_instance_variables
    check_invariants
  end

  def eql?(other)
    self.class == other.class && values == other.values
  end

  def ==(other)
    eql?(other)
  end

  def hash
    self.class.hash ^ values.hash
  end

  protected

  def values
    @values
  end

  private

  def names
    self.class.field_names
  end

  def predicates
    self.class.predicates
  end

  def check_fields_are_initialized
    raise WrongNumberOfArguments.new(names.length, values.length) unless arguments_number_is_right?
    raise FieldWithoutValue.new(uninitialized_field_names) unless all_fields_initialized?
  end

  def set_instance_variables
    names.zip(values) do |name, value|
      instance_variable_set(:"@#{name}", value)
    end
  end

  def arguments_number_is_right?
    values.length == names.length
  end

  def uninitialized_fields
    names.zip(values).select { |name, value| value.nil? }
  end

  def all_fields_initialized?
    uninitialized_fields.empty?
  end

  def uninitialized_field_names
    uninitialized_fields.map { |field| field.first }
  end

  def check_invariants
    return if predicates.nil?

    if predicates[:implicit_invariants]
      valid = instance_eval(&predicates[:implicit_invariants])
      raise ViolatedInvariant.new("implicit", values) unless valid
    end

    if predicates[:explicit_invariants]
      predicates[:explicit_invariants].each do |predicate|
        valid = invariant_holds?(predicate)
        raise ViolatedInvariant.new(predicate, values) unless valid
      end
    end

  end

  def invariant_holds?(predicate_symbol)
    begin
      valid = send(predicate_symbol)
    rescue
      raise NotImplementedInvariant.new(predicate_symbol)
    end
  end

  module ClassMethods
    def field_names
      @field_names
    end

    def predicates
      { implicit_invariants: @predicate_block, explicit_invariants: @predicate_symbols }
    end

    def fields(*names)
      raise NotDeclaredFields.new if names.empty?

      attr_reader(*names)
      @field_names = names
    end

    def invariants(*predicate_symbols, &predicate_block)
      raise BadInvariantDefinition.new if (predicate_symbols.empty? && !block_given?) || (!predicate_symbols.empty? && block_given?)

      @predicate_symbols = predicate_symbols unless block_given?
      @predicate_block = predicate_block
    end
  end

end
