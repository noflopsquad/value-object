require 'exceptions'

module ValueObject

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def fields(*names)
      raise NotDeclaredFields.new() if names.empty?()

      attr_reader(*names)

      define_method(:initialize) do |*values|
        check_fields_are_initialized(values)
        set_instance_variables(values)
        check_invariants()
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

      define_method(:values) do
        names.map { |field| send(field) }
      end
      protected(:values)

      define_method(:check_invariants) do
      end
      private(:check_invariants)

      define_method(:check_fields_are_initialized) do |values|
        raise WrongNumberOfArguments.new(names.length, values.length) unless arguments_number_is_right?(values)
        raise FieldWithoutValue.new(uninitialized_fields_names(values)) unless all_fields_initialized?(values)
      end
      private(:check_fields_are_initialized)

      define_method(:arguments_number_is_right?) do |values|
        fields_number = names.length
        arguments_number = values.length
        values.length == names.length
      end
      private(:arguments_number_is_right?)

      define_method(:uninitialized_fields) do |values|
        names.zip(values).select { |name, value| value.nil? }
      end
      private(:uninitialized_fields)

      define_method(:all_fields_initialized?) do |values|
        uninitialized_fields(values).empty?
      end
      private(:all_fields_initialized?)

      define_method(:uninitialized_fields_names) do |values|
        uninitialized_fields(values).map { |field| field.first }
      end
      private(:uninitialized_fields_names)

      define_method(:set_instance_variables) do |values|
        names.zip(values) do |name, value|
          instance_variable_set(:"@#{name}", value)
        end
      end
      private(:set_instance_variables)
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
end
