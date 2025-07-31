require "./expression"

abstract class Call < Expression
  getter callee : VariableIdentifier
  getter arguments : Array(Expression)

  def initialize(@callee : VariableIdentifier, @arguments : Array(Expression))
  end
end

class ProcedureCall < Call
end

class FunctionCall < Call
end