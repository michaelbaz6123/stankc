require "./node"

class Expression < Node
  property resolved_type : Type?
end

class VariableExpression < Expression
  getter variable : VariableIdentifier

  def initialize(@variable : VariableIdentifier)
  end
end

class UnaryExpression < Expression
  getter operator : TokenType
  getter right : Expression

  def initialize(@operator : TokenType, @right : Expression)
  end
end

class BinaryExpression < Expression
  getter left : Expression
  getter operator : TokenType
  getter right : Expression

  def initialize(@left : Expression, @operator : TokenType, @right : Expression)
  end
end


class IfExpression < Expression
  getter branches : Array(IfBranch(Expression))
  getter else_body : Expression?

  def initialize(@branches : Array(IfBranch(Expression)), @else_body : Expression? = nil)
  end
end

class VarReassignment < Expression
  getter variable_identifier : VariableIdentifier
  getter value : Expression

  def initialize(@variable_identifier : VariableIdentifier, @value : Expression)
  end
end