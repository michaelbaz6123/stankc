class Procedure < Node
  getter statements : Array(Statement)


  def initialize(@statements : Array(Statement))
  end
end