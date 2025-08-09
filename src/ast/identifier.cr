abstract class Identifier < Node
  abstract def name : String?
end


class VariableIdentifier < Identifier
  getter name : String
  getter module_names : Array(String)
  getter accessor_names : Array(String)

  getter source_location : SourceLocation

  def initialize(@name : String, @module_names : Array(String), @accessor_names : Array(String), @source_location : SourceLocation)
  end
end

class TypeIdentifier < Identifier
  getter name : String 
  getter inner_type_ids : Array(TypeIdentifier) 

  getter source_location : SourceLocation

  def initialize(@name : String, @inner_type_ids : Array(TypeIdentifier), @source_location : SourceLocation)
  end
end
