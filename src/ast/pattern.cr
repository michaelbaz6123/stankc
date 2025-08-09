class MatchExpression < Expression
  getter scrutinee : Expression # can match to any expression ...
  getter branches : Array(MatchBranch)

  getter source_location : SourceLocation

  def initialize(@scrutinee : Expression, @branches : Array(MatchBranch), @source_location : SourceLocation)
  end
end

class IfLetStatement < Statement
  getter pattern : Pattern 
  getter scrutinee : Expression
  getter body : Procedure
  getter else_body : Procedure?

  getter source_location : SourceLocation

  def initialize(@pattern : Pattern, @scrutinee : Expression, @body : Procedure, @else_body : Procedure?, @source_location : SourceLocation)
  end
end

class MatchBranch < Node
  getter pattern : Pattern
  getter body : Expression

  property resolved_type : Type?

  getter source_location : SourceLocation

  def initialize(@pattern : Pattern, @body : Expression, @source_location : SourceLocation)
  end
end

abstract class Pattern < Node
end

class WildCardPattern < Pattern
  property resolved_type : Type?

  getter source_location : SourceLocation

  def initialize(@source_location : SourceLocation)
  end
end

class LiteralPattern < Pattern
  getter value : Literal

  getter source_location : SourceLocation

  def initialize(@value : Literal, @source_location : SourceLocation)
  end

end

class BindingPattern < Pattern
  getter name : String

  property resolved_type : Type?

  getter source_location : SourceLocation

  def initialize(@name : String, @source_location : SourceLocation)
  end
end

class NamedFieldPattern < Pattern
  getter field_name : String
  getter pattern : Pattern

  property resolved_type : Type?

  def initialize(@field_name : String, @pattern : Pattern, @source_location : SourceLocation)
  end
end

class VariantPattern < Pattern
  getter variant_name : String
  getter field_patterns : Array(NamedFieldPattern)

  getter source_location : SourceLocation

  def initialize(@variant_name : String, @field_patterns : Array(NamedFieldPattern), @source_location : SourceLocation)
  end
end

class TuplePattern < Pattern
  getter patterns : Array(Pattern)

  getter source_location : SourceLocation

  def initialize(@patterns : Array(Pattern), @source_location : SourceLocation)
  end
end
