require "./call"
require "./declaration"
require "./expression"
require "./identifier"
require "./if_branch"
require "./literal"
require "./procedure"
require "./statement"
require "./pattern"
require "./source_location"
require "../type_checker/type"

class AST < Node
  getter procedure : Procedure
  def initialize(@procedure : Procedure)
  end
end
