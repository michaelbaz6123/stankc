require "./expression"

abstract class Call < Expression
  getter callee : VariableIdentifier
  getter arguments : Array(Expression)

  getter source_location : SourceLocation

  def initialize(@callee : VariableIdentifier, @arguments : Array(Expression), @source_location : SourceLocation)
  end
end

class ProcedureCall < Call
end

class FunctionCall < Call
end