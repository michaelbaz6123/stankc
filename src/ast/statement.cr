abstract class Statement < Node
end

class ExpressionStatement < Statement
  getter expression : Expression

  def initialize(@expression : Expression)
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
  getter branches : Array(IfBranch(Procedure))
  getter else_body : Procedure?

  def initialize(@branches : Array(IfBranch(Procedure)), @else_body : Procedure? = nil)
  end
end