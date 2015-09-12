value-object
============
[![License MIT](http://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/noflopsquad/valueobjects.svg?branch=master)](https://travis-ci.org/noflopsquad/valueobjects)
[![Code Climate](https://codeclimate.com/github/noflopsquad/valueobjects/badges/gpa.svg)](https://codeclimate.com/github/noflopsquad/valueobjects)
[![Test Coverage](https://codeclimate.com/github/noflopsquad/valueobjects/badges/coverage.svg)](https://codeclimate.com/github/noflopsquad/valueobjects/coverage)

A simple module to provide value objects semantics to a class.


## Usage

### Constructor and field readers

```ruby
require 'value_object'

class Point
  extend ValueObject
  fields :x, :y
end

point = Point.new(1, 2)
# => #<Point:0x00000001d1a780 @x=1, @y=2>

point.x
# => 1

point.y
# => 2

point.x = 3
# NoMethodError: undefined method `x=' for #<Point:0x00000001d1a780 @x=1, @y=2>
```

### Equality based on field values

```ruby
require 'value_object'

class Point
  extend ValueObject
  fields :x, :y
end

a_point = Point.new(5, 3)
# => #<Point:0x8d86c1c @x=5, @y=3>

same_point = Point.new(5, 3)
# => #<Point:0x8d7b858 @x=5, @y=3>

a_point == same_point
# => true

a_point.eql?(same_point)
# => true

a_different_point = Point.new(6, 3)
# => #<Point:0x8d6597c @x=6, @y=3>

a_point == a_different_point
# => false

a_point.eql?(a_different_point)
# => false
```

### Hash code based on field values

```ruby
require 'value_object'

class Point
  extend ValueObject
  fields :x, :y
end

a_point = Point.new(5, 3)
# => #<Point:0x8d86c1c @x=5, @y=3>

same_point = Point.new(5, 3)
# => #<Point:0x8d7b858 @x=5, @y=3>

a_point.hash == same_point.hash
# => true

a_different_point = Point.new(6, 3)
# => #<Point:0x8d6597c @x=6, @y=3>

a_point.hash == a_different_point.hash
# => false
```

### Invariants

You can declare invariants to restrict field values on initialization

```ruby
require 'value_object'

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

Point.new(-5, 3)
# ValueObject::ViolatedInvariant: Fields values [-5, 3] violate invariant: inside_first_cuadrant

Point.new(6, 3)
# ValueObject::ViolatedInvariant: Fields values [6, 3] violate invariant: x_less_than_y

Point.new(1, 3)
# => #<Point:0x894aacc @x=1, @y=3>
```
