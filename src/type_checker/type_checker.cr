require "./type_env"
require "./type_error"

class TypeChecker
  @env : TypeEnv

  def initialize
    @env = TypeEnv.new
  end

  def check(ast : AST)
    check_procedure(ast.procedure)
  end

  private def check_procedure(proc : Procedure)
    proc.statements.each do |stmt|
      check_statement(stmt)
    end
  end

  private def check_statement(stmt : Statement)
    case stmt
    when Binding
      check_binding(stmt)
    when ProductTypeDeclaration
      check_product_type_declatation(stmt)
    when FunctionDeclaration
      check_function_declaration(stmt)
    when ProcedureDeclaration
      check_procedure_declaration(stmt)
    else
      raise error("Unsupported statement: #{stmt.class}")
    end
  end

  private def check_expr(expr : Expression) : Type
    case expr
    when IntLiteral
      builtin_type("I32")
    when FloatLiteral
      builtin_type("F64")
    when BoolLiteral
      builtin_type("Bool")
    when VariableExpression
      name = expr.variable.names.first.raw
      type = @env.lookup(name)
      raise error("Undefined variable: #{name}") unless type
      type
    when BinaryExpression
      lhs_type = check_expr(expr.left)
      rhs_type = check_expr(expr.right)

      case expr.operator
      when TokenType::ADD
        if lhs_type == rhs_type && is_numeric_type(lhs_type)
          lhs_type
        else
          raise error("Type error: cannot apply '+' to #{lhs_type.name.raw} and #{rhs_type.name.raw}")
        end
      else
        raise error("Unsupported binary operator #{expr.operator}")
      end
    else
      raise error("Unhandled expression type: #{expr.class}")
    end
  end

  private def check_binding(binding : Binding)
    name = binding.name
    type_id = binding.type_identifier
    value_type = check_expr(binding.value)
    if type_id = type_id
      annotation_type = parse_type(type_id.name)
      unless annotation_type == value_type
        raise error("Type mismatch in binding '#{name}': expected #{expected.name.raw}, got #{actual.name.raw}")
      end
    end

    

    @env.declare(name, expected)
  end

  private def check_function_declaration(declaration : FunctionDeclaration)

  end

  private def check_product_type_declatation(declaration : ProductTypeDeclaration)
    # ensure types in fields are either in scope OR a generic attached
    # in the product type declaration name MyType<T>
  end

  private def check_procedure_declaration(declaration : ProcedureDeclaration)
    # ensure 
  end

  # Reuse the type from the AST's declared type node
  private def parse_type(type_node : Type) : Type
    type_node # assumes all type nodes are already canonical Type instances
  end

  private def builtin_type(name : String) : Type
    Type.new(Name.new(name))
  end

  private def is_numeric_type(type : Type) : Bool
    raw = type.name.raw
    raw == "I32" || raw == "F64"
  end

  private def error(message : String) : TypeError
    TypeError.new(message)
  end
end
