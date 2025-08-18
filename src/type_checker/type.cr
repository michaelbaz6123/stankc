abstract class Type
  abstract def to_s : String
  abstract def ==(other : Type) : Bool
  abstract def generic? : Bool
end

# Generic type parameter, e.g. T
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

  def_hash name

end

# Atomic named type
class NamedType < Type
  getter name : String

  def initialize(@name : String)
  end

  def to_s : String
    name
  end

  def ==(other : Type) : Bool
    other.is_a?(NamedType) && other.name == name
  end

  def generic? : Bool
    false
  end

end

# Product type, i.e. structured type with fields
class ProductType < NamedType
  property fields : Array(Type) # mutable for generic sub

  def initialize(name : String, @fields : Array(Type))
    super(name)
  end

  def to_s : String
    "#{name}(#{fields.map(&.to_s).join(", ")})"
  end

  def ==(other : Type) : Bool
    other.is_a?(ProductType) &&
      super(other) &&
      fields.size == other.fields.size &&
      fields.zip(other.fields).all? { |a,b| a == b }
  end

  def generic? : Bool
    fields.any?(&.generic?)
  end

end

# Union type, i.e. type alias for variants
class UnionType < NamedType
  property variants : Array(Type) # mutable for generic sub

  def initialize(name : String, @variants : Array(Type))
    super(name)
  end

  def to_s : String
    variants.map(&.to_s).join(" | ")
  end

  def ==(other : Type) : Bool
    other.is_a?(UnionType) &&
      super(other) &&
      variants.size == other.variants.size &&
      variants.zip(other.variants).all? { |a,b| a == b }
  end

  def generic? : Bool
    variants.any?(&.generic?)
  end

end

# Function type
class FunctionType < Type
  getter param_types : Array(Type)
  getter return_type : Type

  def initialize(@param_types : Array(Type), @return_type : Type)
  end

  def to_s : String
    "(#{param_types.map(&.to_s).join(", ")}) -> #{return_type.to_s}"
  end

  def ==(other : Type) : Bool
    other.is_a?(FunctionType) &&
      return_type == other.return_type &&
      param_types.size == other.param_types.size &&
      param_types.zip(other.param_types).all? { |a,b| a == b }
  end

  def generic? : Bool
    param_types.any?(&.generic?) || return_type.generic?
  end

  def name : String
    to_s
  end

end
