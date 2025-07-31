abstract class Identifier < Node
  abstract def name : String
end


class VariableIdentifier < Identifier
  getter name : String
  getter module_names : Array(String)
  getter accessor_names : Array(String)

  def initialize(@name : String, @module_names : Array(String), @accessor_names : Array(String))
  end
end

class TypeIdentifier < Identifier
  getter name : String
  getter inner_type_ids : Array(TypeIdentifier)

  def initialize(@name : String, @inner_type_ids : Array(TypeIdentifier))
  end
end