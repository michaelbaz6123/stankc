require "./statement"

abstract class Declaration < Statement
end

class ModuleDeclaration < Declaration
  getter name : String
  getter procedure : Procedure
  def initialize(@name : String, @procedure : Procedure)
  end
end

class Binding < Declaration
  getter name : String
  getter value : Expression
  getter type_identifier : TypeIdentifier?
  
  getter resolved_type : Type?

  def initialize(@name : String, @value : Expression, type_identifier : TypeIdentifier? = nil)
  end

end

class VarDeclaration < Declaration
  getter name : String
  getter value : Expression?
  getter type_identifier : TypeIdentifier? 

  getter resolved_type : Type?

  def initialize(@name : String, @value : Expression?, @type_identifier : TypeIdentifier? = nil)
  end
end

class Parameter < Node
  getter name : String
  getter type_identifier : TypeIdentifier

  getter resolved_type : Type?

  def initialize(@name : String, @type_identifier : TypeIdentifier)
  end
end

class FunctionDeclaration < Declaration
  getter name : String
  getter params : Array(Parameter)
  getter generics : Array(String)
  getter body : Expression
  getter return_type_identifier : TypeIdentifier? 

  getter resolved_type : Type?

  def initialize(@name : String, @params : Array(Parameter), @generics : Array(String), @body : Expression, @return_type_identifier : TypeIdentifier? = nil)
  end
end

class ProcedureDeclaration < Declaration
  getter name : String
  getter params : Array(Parameter)
  getter generics : Array(String)
  getter body : Procedure

  getter resolved_type : Type?

  def initialize(@name : String, @params : Array(Parameter), @generics : Array(String), @body : Procedure)
  end
end

class Field < Parameter
end

class ProductTypeDeclaration < Declaration
  getter name : String
  getter generics : Array(String)
  getter fields : Array(Field)

  getter resolved_type : Type?

  def initialize(@name : String, @generics : Array(String), @fields : Array(Field))
  end
end

class UnionTypeDeclaration < Declaration
  getter name : String
  getter generics : Array(String)
  getter variants : Array(TypeIdentifier)

  getter resolved_type : Type?

  def initialize(@name : String, @generics : Array(String), @variants : Array(TypeIdentifier))
  end
end