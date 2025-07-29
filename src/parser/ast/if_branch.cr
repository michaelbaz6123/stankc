class IfBranch < Node
  getter condition : Expression
  getter body : Procedure | Expression 

  def initialize(@condition : Expression, @body : Procedure | Expression)
  end
end