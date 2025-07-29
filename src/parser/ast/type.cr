class Type < Expression
  getter raw : String
  getter inner_types : Array(Type)
  def initialize(@raw : String, @inner_types)
  end
end