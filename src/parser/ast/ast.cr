require "./call"
require "./expression"
require "./if_branch"
require "./literal"
require "./name"
require "./node"
require "./procedure"
require "./statement"
require "./type"
require "./typed_name"
require "./variable"

class AST < Node
  getter procedure : Procedure
  def initialize(@procedure : Procedure)
  end
end
