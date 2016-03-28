require 'spec_helper'
require './lib/value_object'

describe "ValueObject" do

  describe "standard behavior" do
    class Point
      include ValueObject
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
      it "must have at least one field" do
        expect {
          class Point
            include ValueObject
            fields
          end
        }.to raise_error(ValueObject::NotDeclaredFields)
      end
    end

    describe "on initialization" do
      it "must not have any field initialized to nil" do
        class Point
          include ValueObject
          fields :x, :y
        end

        expect {
          Point.new 1, nil
        }.to raise_error(ValueObject::FieldWithoutValue, "Declared fields [:y] must have value")

      end

      it "must have number of values equal to number of fields" do
        class Point
          include ValueObject
          fields :x, :y
        end

        expect {
          Point.new(1)
        }.to raise_error(ValueObject::WrongNumberOfArguments)

        expect {
          Point.new(1, 2, 3) 
        }.to raise_error(ValueObject::WrongNumberOfArguments, "Declared 2 fields but passing 3")
      end
    end
  end

  describe "forcing invariants" do
    describe "on declaration" do
      it "some invariant must be defined" do
        expect {
          class Point
            include ValueObject
            fields :x, :y
            invariants
          end
        }.to raise_error(ValueObject::BadInvariantDefinition)
      end

      it "cannot define both implicit and explicit invariants" do
        expect {
          class Point
            include ValueObject
            fields :x, :y
            invariants :x_less_than_y, :inside_first_quadrant do
              y % 2 == 0
            end
          end
        }.to raise_error(ValueObject::BadInvariantDefinition)
      end
    end

    describe "on initialization" do

      it "forces implicit invariants with several conditions" do
        class Point
          include ValueObject
          fields :x, :y
          invariants do
            x < y
          end
        end

        expect {
          Point.new(6, 3)
        }.to raise_error(ValueObject::ViolatedInvariant, "Field values [6, 3] violate invariant: implicit")
      end

      it "forces implicit invariants" do
        class Point
          include ValueObject
          fields :x, :y
          invariants do
            x < y
          end
        end

        expect {
          Point.new(6, 3)
        }.to raise_error(ValueObject::ViolatedInvariant, "Field values [6, 3] violate invariant: implicit")
      end

      it "forces explicit invariants" do
        class Point
          include ValueObject
          fields :x, :y
          invariants :x_less_than_y, :inside_first_quadrant

          private
          def x_less_than_y
            x < y
          end

          def inside_first_quadrant
            x > 0 && y > 0
          end
        end

        expect {
          Point.new(6, 3)
        }.to raise_error(ValueObject::ViolatedInvariant, "Field values [6, 3] violate invariant: x_less_than_y")

        expect {
          Point.new(-5, 3)
        }.to raise_error(ValueObject::ViolatedInvariant, "Field values [-5, 3] violate invariant: inside_first_quadrant")
      end

      it "raises an exception when a declared invariant has not been implemented" do
        class Point
          include ValueObject
          fields :x, :y
          invariants :integers
        end

        expect {
          Point.new(5, 2)
        }.to raise_error(ValueObject::NotImplementedInvariant, "Invariant integers needs to be implemented")
      end
    end
  end
end
