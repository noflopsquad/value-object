require 'spec_helper'
require "./lib/value_object"

describe "ValueObject" do

  describe "standard behavior" do
    class Point
      extend ValueObject
      fields :x, :y
    end

    it "generates constructor, fields and accessors for declared fields" do
      a_value_object = Point.new(5, 3)

      expect(a_value_object.x).to eq(5)
      expect(a_value_object.y).to eq(3)
    end

    it "provides equality based on declared fields values" do
      a_value_object = Point.new(5, 3)
      same_value_object = Point.new(5, 3)
      different_value_object = Point.new(6, 3)

      expect(a_value_object).to eq(same_value_object)
      expect(a_value_object).to_not eq(different_value_object)
    end

    it "provides hash code generation based on declared fields values" do
      a_value_object = Point.new(5, 3)
      same_value_object = Point.new(5, 3)
      different_value_object = Point.new(6, 3)

      expect(a_value_object.hash).to eq(same_value_object.hash)
      expect(a_value_object.hash).to_not eq(different_value_object)
    end
  end

  describe "restrictions" do
    describe "on declaration" do
      it "must at least have one field" do
        expect do
          class DummyWithNoFieldsUsingFieldsMethod
            extend ValueObject
            fields
          end
        end.to raise_error(ValueObject::NotDeclaredFields)
      end
    end

    describe "on initialization" do
      it "must not have any field initialized to nil" do
        class DummyWithDeclaredFieldsWithoutValue
          extend ValueObject
          fields :x, :y
        end

        expect{
          DummyWithDeclaredFieldsWithoutValue.new 1, nil
          }.to raise_error(ValueObject::FieldWithoutValue, "Declared fields [:y] must have value")
        
      end
      
      it "must have number of values equal to number of fields" do
        class Point
          extend ValueObject
          fields :x, :y
        end
 
        expect{
          Point.new(1)
          }.to raise_error(ValueObject::WrongNumberOfArguments)
        

        expect{ Point.new(1, 2, 3) }.to raise_error(ValueObject::WrongNumberOfArguments, "Declared 2 fields but passing 3")
      end
    end
  end

  describe "forcing invariants" do
    it "forces declared invariants" do
      class Point
        extend ValueObject
        fields :x, :y
        invariants :x_less_than_y, :inside_first_quadrant

        private
        def inside_first_quadrant
          x > 0 && y > 0
        end

        def x_less_than_y
          x < y
        end
      end

      expect{ Point.new(-5, 3) }.to raise_error(
        ValueObject::ViolatedInvariant, "Fields values [-5, 3] violate invariant: inside_first_quadrant"
      )

      expect{ Point.new(6, 3) }.to raise_error(
        ValueObject::ViolatedInvariant, "Fields values [6, 3] violate invariant: x_less_than_y"
      )
    end

    it "raises an exception when a declared invariant has not been implemented" do
      class PairOfIntegers
        extend ValueObject
        fields :x, :y
        invariants :integers
      end

      expect{ PairOfIntegers.new(5, 2) }.to raise_error(
        ValueObject::NotImplementedInvariant, "Invariant integers needs to be implemented"
      )
    end
  end
end
