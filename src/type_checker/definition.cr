class TypeDefinition
  # All types can have parents (for type unions)
  property : Array(TypeDefinition) = [] of TypeDefinition
end

class AtomicTypeDefinition < TypeDefinition
  getter name : String
  def initialize(@name : String)
  end
end

class ProductTypeDefinition < TypeDefinition
  getter name : String
  property fields : Hash(String, Type)
  getter constructor : ConstructorDefinition

  def initialize(@name : String, @fields : Hash(String, Type), @constructor : ConstructorDefinition)
  end
end

class UnionTypeDefinition < TypeDefinition
  getter name : String
  getter variants : Array(Type)

  def initialize(@name : String, @variants : Array(Type))
  end
end

class FunctionDefinition
  getter name : String
  getter resolved_type : FunctionType

  def initialize(@name : String, @resolved_type : FunctionType)
  end
end

class ProcedureDefinition < FunctionDefinition
end

class ConstructorDefinition < FunctionDefinition
end