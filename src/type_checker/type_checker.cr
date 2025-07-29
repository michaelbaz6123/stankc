require "./type_env"

class TypeChecker
  @env : TypeEnv

  def initialize
    @env = TypeEnv.new
  end

  def check(ast : AST)
    check_procedure(ast.procedure)
  end
end
