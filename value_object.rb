class NotImplementedInvariant < Exception
  def initialize(name)
    super "The invariant #{name} is not implemented"
  end
end

class ViolatedInvariant < Exception
  def initialize(name, wrong_values)
    super "Fields values " + wrong_values.to_s + " violate invariant #{name}"
  end
end

module ValueObject
  BUILT_IN_INVARIANTS = {
    :integers => Proc.new do |obj|
      obj.values.all? {|value| value.is_a? Integer}
    end
  }

  def fields(*names)
    attr_reader(*names)

    define_method(:initialize) do |*values|
      names.zip(values) do |name, value|
        instance_variable_set(:"@#{name}", value)
      end
      check_invariant
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

  def invariants(*predicates)
    define_method(:check_invariant) do
      predicates.each do |predicate|
        begin
          res = send(predicate)
        rescue
          proc = BUILT_IN_INVARIANTS[predicate]

          raise NotImplementedInvariant.new(predicate) unless proc

          res = proc.call(self) if proc
        end

        raise ViolatedInvariant.new(predicate, self.values) unless res
      end
    end
  end
end
