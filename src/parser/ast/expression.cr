require "./node"

abstract class Expression < Node
end

class Literal < Expression
  getter literal_value : LiteralValue

  def initialize(@literal_value : LiteralValue)
  end
end

class VariableExpression < Expression
  getter variable : Variable

  def initialize(@variable : Variable)
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

class TupleExpression < Expression
  getter args : Array(Expression)

  def initialize(@args : Array(Expression))
  end
end

class IfExpression < Expression
  getter branches : Array(IfBranch)
  getter else_body : Expression?

  def initialize(@branches : Array(IfBranch), @else_body : Expression? = nil)
  end
end

class Reassignment < Expression
  getter variable : Variable
  getter value : Expression

  def initialize(@variable : Variable, @value : Expression)
  end
end