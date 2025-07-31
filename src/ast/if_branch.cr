class IfBranch(BodyType) < Node
  getter condition : Expression
  getter body : BodyType

  def initialize(@condition : Expression, @body : BodyType)
  end
end