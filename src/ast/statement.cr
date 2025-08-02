abstract class Statement < Node
end

class ExpressionStatement < Statement
  getter expression : Expression

  getter source_location : SourceLocation

  def initialize(@expression : Expression, @source_location : SourceLocation)
  end
end

class WhileLoop < Statement
  getter condition : Expression
  getter body : Procedure

  getter source_location : SourceLocation

  def initialize(@condition : Expression, @body : Procedure, @source_location : SourceLocation)
  end
end

class Break < Statement
  getter source_location : SourceLocation
  def initialize(@source_location : SourceLocation)
  end
end

class IfStatement < Statement
  getter branches : Array(IfBranch(Procedure))
  getter else_body : Procedure?

  getter source_location : SourceLocation

  def initialize(@branches : Array(IfBranch(Procedure)), @else_body : Procedure?, @source_location : SourceLocation)
  end
end