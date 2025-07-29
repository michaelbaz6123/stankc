abstract class Statement < Node
end

class Binding < Statement
  getter typed_name : TypedName
  getter value : Expression

  def initialize(@typed_name : TypedName, @value : Expression)
  end
end

class VarDeclaration < Statement
  getter typed_name : TypedName
  getter value : Expression?

  def initialize(@typed_name : TypedName, @value : Expression?)
  end
end

class ExpressionStatement < Statement
  getter expression : Expression

  def initialize(@expression : Expression)
  end
end

class FunctionDeclaration < Statement
  getter typed_name : TypedName
  getter args : Array(TypedName)
  getter body : Expression

  def initialize(@typed_name : TypedName, @args : Array(TypedName), @body : Expression)
  end
end

class ProcedureDeclaration < Statement
  getter name : Name
  getter args : Array(TypedName)
  getter body : Procedure

  def initialize(@name : Name, @args : Array(TypedName), @body : Procedure)
  end
end

class StructDeclaration < Statement
  getter name : Name
  getter fields : Array(TypedName)

  def initialize(@name : Name, @fields : Array(TypedName))
  end
end


class WhileLoop < Statement
  getter condition : Expression
  getter body : Procedure

  def initialize(@condition : Expression, @body : Procedure)
  end
end

class Break < Statement
end

class Return < Statement
end

class IfStatement < Statement
  getter branches : Array(IfBranch)
  getter else_body : Procedure?

  def initialize(@branches : Array(IfBranch), @else_body : Procedure? = nil)
  end
end