class MatchExpression < Expression
  getter scrutinee : Expression # can match to any expression ...
  getter branches : Array(MatchBranch)

  def initialize(@scrutinee : Expression, @branches : Array(MatchBranch))
  end
end

class IfLetStatement < Statement
  getter pattern : Pattern # ... but if let must match to a single identifier
  getter scrutinee : Expression
  getter body : Procedure
  getter else_body : Procedure?

  def initialize(@pattern : Pattern, @scrutinee : Expression, @body : Procedure, @else_body : Procedure? = nil)
  end
end

class MatchBranch < Node
  getter pattern : Pattern
  getter body : Expression

  def initialize(@pattern : Pattern, @body : Expression)
  end
end

abstract class Pattern < Node
end

class WildCardPattern < Pattern
end

class LiteralPattern < Pattern
  getter value : Literal
  def initialize(@value : Literal)
  end
end

class BindingPattern < Pattern
  getter name : String
  property resolved_type : Type?
  def initialize(@name : String)
  end
end

class NamedFieldPattern < Pattern
  getter field_name : String
  getter pattern : Pattern
  property resolved_type : Type?

  def initialize(@field_name : String, @pattern : Pattern)
  end
end

class VariantPattern < Pattern
  getter variant_name : String
  getter field_patterns : Array(NamedFieldPattern)

  def initialize(@variant_name : String, @field_patterns : Array(NamedFieldPattern))
  end
end
