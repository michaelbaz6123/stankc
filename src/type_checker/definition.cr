abstract class TypeDefinition
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
  getter constructor : ConstructorDefinition

  def initialize(@name : String, @variants : Hash(String, Type), @constructor : ConstructorDefinition)
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