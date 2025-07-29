class Variable < Node
  getter names : Array(Name)

  def initialize(@names : Array(Name))
  end
end