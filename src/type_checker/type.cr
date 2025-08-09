
abstract class Type
  abstract def to_s : String
  abstract def ==(other : Type) : Bool
  abstract def generic? : Bool
end


# A generic type parameter, i.e. T in MyType<T>
class GenericTypeParameter < Type
  getter name : String

  def initialize(@name : String)
  end

  def to_s : String
    name
  end

  def ==(other : Type) : Bool
    other.is_a?(GenericTypeParameter) && other.name == name
  end

  def generic? : Bool
    true
  end
end

# Named type with generic parameters or concrete types
class NamedType < Type
  getter name : String
  property type_arguments : Array(Type)

  def initialize(@name : String, @type_arguments : Array(Type) = [] of Type)
  end

  def to_s : String
    if type_arguments.empty?
      name
    else
      "#{name}(#{type_arguments.map(&.to_s).join(", ")})"
    end
  end

  def generic? : Bool
    !type_arguments.empty? && type_arguments.all? do |type|
      type.generic?
    end
  end

  def ==(other : Type) : Bool
    other.is_a?(NamedType) &&
      other.name == name &&
      other.type_arguments.size == type_arguments.size &&
      other.type_arguments.zip(type_arguments).all? { |o, s| o == s }
  end
end

# Function types, e.g. (Int, Bool) -> String
class FunctionType < Type
  getter param_types : Array(Type)
  getter return_type : Type

  def initialize(@param_types : Array(Type), @return_type : Type)
  end

  def to_s : String
    params = param_types.map(&.to_s).join(", ")
    "(#{params}) -> #{return_type.to_s}"
  end

  def generic? : Bool
    param_types.any? { |pt| pt.generic? }
  end

  def ==(other : Type) : Bool
    other.is_a?(FunctionType) &&
      other.return_type == return_type &&
      other.param_types.size == param_types.size &&
      other.param_types.zip(param_types).all? { |o, s| o == s }
  end

  def name : String
    to_s
  end
end