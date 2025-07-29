require "./expression"

abstract class Call < Expression
  getter callee : Variable
  getter args : TupleExpression

  def initialize(@callee : Variable, @args : TupleExpression)
  end
end

class ProcedureCall < Call
end

class FunctionCall < Call
end