class IfBranch(BodyType) < Node
  getter condition : Expression
  getter body : BodyType

  getter source_location : SourceLocation

  def initialize(@condition : Expression, @body : BodyType, @source_location : SourceLocation)
  end
end