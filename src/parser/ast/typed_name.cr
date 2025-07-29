class TypedName < Node
  getter name : Name
  getter type : Type
  def initialize(@name : Name, @type : Type)
  end
end