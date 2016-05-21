require './lib/value_object'

class Point
  include ValueObject
  fields :x, :y
end

puts Point.new(5, 3).hash()
