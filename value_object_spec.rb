require "./value_object"

describe "a value object" do

  class Point
    extend ValueObject
    fields :x, :y
    invariants :inside_first_cuadrant, :integers

    private
    def inside_first_cuadrant
      x > 0 && y > 0
    end
  end

  it "declaratively generates a constructor, fields and accessors" do
    a_value_object = Point.new(5, 3)

    expect(a_value_object.x).to eq(5)
    expect(a_value_object.y).to eq(3)
  end

  it "provides value object equality" do
    a_value_object = Point.new(5, 3)
    same_value_object = Point.new(5, 3)
    different_value_object = Point.new(6, 3)

    expect(a_value_object).to eq(same_value_object)
    expect(a_value_object).to_not eq(different_value_object)
  end

  it "provides a to_a method" do
    a_value_object = Point.new(5, 3)

    expect(a_value_object.to_a).to eq([5, 3])
  end

  it "forces invariants declarated on all fields" do
    expect{Point.new(-5, 3)}.to raise_error(
      ViolatedInvariant, "Fields values [-5, 3] violate invariant inside_first_cuadrant"
    )
  end

  it "provides a built-in invariant for integer values" do
    expect{Point.new(5.2, 3)}.to raise_error(
      ViolatedInvariant, "Fields values [5.2, 3] violate invariant integers"
    )
  end

  it "raises an exception when an invariant has not been implemented" do
    class Dummy
      extend ValueObject
      fields :x
      invariants :not_implemented
    end

    expect{Dummy.new(5)}.to raise_error(
      NotImplementedInvariant, "The invariant not_implemented is not implemented"
    )
  end
end
