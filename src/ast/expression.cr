require "./node"

class Expression < Node
  property resolved_type : Type?

  getter source_location : SourceLocation
  def initialize(@source_location : SourceLocation)
  end
end

class VariableExpression < Expression
  getter variable : VariableIdentifier

  getter source_location : SourceLocation

  def initialize(@variable : VariableIdentifier, @source_location : SourceLocation)
  end
end

class UnaryExpression < Expression
  getter operator : TokenType
  getter right : Expression

  getter source_location : SourceLocation

  def initialize(@operator : TokenType, @right : Expression, @source_location : SourceLocation)
  end
end

class BinaryExpression < Expression
  getter left : Expression
  getter operator : TokenType
  getter right : Expression

  getter source_location : SourceLocation

  def initialize(@left : Expression, @operator : TokenType, @right : Expression, @source_location : SourceLocation)
  end
end


class IfExpression < Expression
  getter branches : Array(IfBranch(Expression))
  getter else_body : Expression?

  getter source_location : SourceLocation

  def initialize(@branches : Array(IfBranch(Expression)), @else_body : Expression?, @source_location : SourceLocation)
  end
end


class VarReassignment < Expression
  getter variable_identifier : VariableIdentifier
  getter value : Expression

  getter source_location : SourceLocation

  def initialize(@variable_identifier : VariableIdentifier, @value : Expression, @source_location : SourceLocation)
  end
end