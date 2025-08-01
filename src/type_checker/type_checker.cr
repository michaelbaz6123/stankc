require "./type_env"
require "./type_error"
require "./type"

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
    resolved_type = case expr
    when IntLiteral
      NamedType.new("Int")
    when FloatLiteral
      NamedType.new("Float")
    when BoolLiteral
      NamedType.new("Bool")
    when VariableExpression
      name = expr.variable.name
      # module_names = expr.variable.module_names
      type = @env.lookup(name) # TODO add module namespace lookup
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
          raise error("Type error: cannot apply '+' to #{lhs_type.name} and #{rhs_type.name}")
        end
      else
        raise error("Unsupported binary operator #{expr.operator}")
      end
    else
      raise error("Unhandled expression type: #{expr.class}")
    end
    expr.resolved_type = resolved_type
  end

  private def check_binding(binding : Binding)
    name = binding.name
    maybe_type_id = binding.type_identifier
    value_type = check_expr(binding.value)
    resolved_type = value_type
    if type_id = maybe_type_id
      annotation_type = parse_type_identifier(type_id)
      unless annotation_type == value_type
        raise error("Type mismatch in binding '#{name}': expected #{annotation_type.name}, got #{value_type.name}")
      end
      resolved_type = annotation_type
    end

    binding.resolved_type = resolved_type
    @env.declare(name, resolved_type)
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

  # AST type identifier from user type annotations to resolved type
  private def parse_type_identifier(type_identifier : TypeIdentifier) : Type
    name = type_identifier.name
    type_arguments = [] of Type
    type_identifier.inner_type_ids.each do |id|
      type_arguments << parse_type_identifier(id)
    end
    return NamedType.new(name, type_arguments)
  end

  private def builtin_type(name : String) : Type
    Type.new(Name.new(name))
  end

  private def is_numeric_type(type : Type) : Bool
    raw = type.name
    raw == "Int" || raw == "Float"
  end

  private def error(message : String) : TypeError
    TypeError.new(message)
  end
end
