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

    it "generates same hash code on different ruby processes" do
      rd1, wr1 = IO.pipe
      rd2, wr2 = IO.pipe
      pid1 = spawn("ruby ./spec/test_program.rb", :out=>wr1)
      pid2 = spawn("ruby ./spec/test_program.rb", :out=>wr2)
      wr1.close
      wr2.close
      _1, status1 = Process.waitpid2(pid1)
      _2, status2 = Process.waitpid2(pid2)

      first_process_object_hash = rd1.read
      second_process_object_hash = rd2.read

      expect(first_process_object_hash).to eq(second_process_object_hash)
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
    it "forces declared invariants" do
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
      }.to raise_error(ValueObject::ViolatedInvariant, "Fields values [6, 3] violate invariant: x_less_than_y")

      expect {
        Point.new(-5, 3)
      }.to raise_error(ValueObject::ViolatedInvariant, "Fields values [-5, 3] violate invariant: inside_first_quadrant")
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
