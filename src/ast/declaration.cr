require "./statement"

abstract class Declaration < Statement
end

class ModuleDeclaration < Declaration
  getter name : String
  getter procedure : Procedure

  getter source_location : SourceLocation

  def initialize(@name : String, @procedure : Procedure, @source_location : SourceLocation)
  end
end

class Binding < Declaration
  getter name : String
  getter value : Expression
  getter type_identifier : TypeIdentifier?

  getter source_location : SourceLocation
  
  property resolved_type : Type?

  def initialize(@name : String, @value : Expression, @type_identifier : TypeIdentifier?, @source_location : SourceLocation)
  end

end

class VarDeclaration < Declaration
  getter name : String
  getter value : Expression?
  getter type_identifier : TypeIdentifier? 

  getter source_location : SourceLocation

  property resolved_type : Type?

  def initialize(@name : String, @value : Expression?, @type_identifier : TypeIdentifier?, @source_location : SourceLocation)
  end
end

class Parameter < Node
  getter name : String
  getter type_identifier : TypeIdentifier

  getter source_location : SourceLocation

  property resolved_type : Type?

  def initialize(@name : String, @type_identifier : TypeIdentifier, @source_location : SourceLocation)
  end
end

class FunctionDeclaration < Declaration
  getter name : String
  getter params : Array(Parameter)
  getter generics : Array(String)
  getter body : Expression
  getter return_type_identifier : TypeIdentifier? 

  getter source_location : SourceLocation

  property resolved_type : Type?

  def initialize(@name : String, @params : Array(Parameter), @generics : Array(String), @body : Expression, @return_type_identifier : TypeIdentifier?, @source_location : SourceLocation)
  end
end

class ProcedureDeclaration < Declaration
  getter name : String
  getter params : Array(Parameter)
  getter generics : Array(String)
  getter body : Procedure

  getter source_location : SourceLocation

  property resolved_type : Type?

  def initialize(@name : String, @params : Array(Parameter), @generics : Array(String), @body : Procedure, @source_location : SourceLocation)
  end
end

class Field < Parameter
end

class ProductTypeDeclaration < Declaration
  getter name : String
  getter generics : Array(String)
  getter fields : Array(Field)

  getter source_location : SourceLocation

  def initialize(@name : String, @generics : Array(String), @fields : Array(Field), @source_location : SourceLocation)
  end
end

class UnionTypeDeclaration < Declaration
  getter name : String
  getter generics : Array(String)
  getter variants : Array(TypeIdentifier)

  getter source_location : SourceLocation

  def initialize(@name : String, @generics : Array(String), @variants : Array(TypeIdentifier), @source_location : SourceLocation)
  end
end