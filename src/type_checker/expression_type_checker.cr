module ExpressionTypeChecker

  private def check_expression(expr : Expression) : Type
    resolved_type = case expr
    when IntLiteral
      NamedType.new("Int")
    when FloatLiteral
      NamedType.new("Float")
    when BoolLiteral
      NamedType.new("Bool")
    when StringLiteral
      NamedType.new("String")
    when CharLiteral
      NamedType.new("Char")
    # TODO add array, hash, and tuple literals
    when VariableExpression
      check_variable_expression(expr)
    when BinaryExpression
      check_binary_expression(expr)
    when FunctionCall
      check_call(expr)
    when ProcedureCall  
      check_procedure_call(expr)
    else
      raise error("Unhandled expression type: #{expr.class}")
    end
    expr.resolved_type = resolved_type
  end

  # TODO
  # private def check_array_literal(expr : ArrayLiteral) : Type

  # end

  private def check_variable_expression(expression : VariableExpression) : Type
    name = expression.variable.name
    type = @env.lookup(name) # TODO add module namespace lookup
    raise error("Undefined variable: #{name}") unless type
    # type.accessor_names.each do | accessor_name |

    # end

    type
  end

  private def check_binary_expression(expression : BinaryExpression) : Type
    lhs_type = check_expression(expression.left)
    rhs_type = check_expression(expression.right)

    case expression.operator
    when TokenType::ADD
      if lhs_type == rhs_type && is_numeric_type(lhs_type)
        return lhs_type
      else
        raise error("Type error: cannot apply '+' to #{lhs_type.name} and #{rhs_type.name}")
      end
    # TODO add other binary operators -, *, /, //, %
    else
      raise error("Unsupported binary operator #{expression.operator}")
    end
  end

  private def check_call(expression : Call) : Type
    name = expression.callee.name
    function_type = @env.lookup(name)
    if ft = function_type
      raise error("#{name} is a variable, not a function") unless ft.is_a?(FunctionType)
      ft = ft.as(FunctionType)
      if (a = expression.arguments.size) != (b = ft.param_types.size)
        raise error("#{name} expected #{b} argument(s) but received #{a}")
      end
      expression.arguments.zip(ft.param_types) do |arg, expected_arg_type|
        arg_type = check_expression(arg)
        unless arg_type == expected_arg_type
          raise error("#{name} expected #{expected_arg_type.to_s} but received #{arg_type.to_s}")
        end
      end

      return ft.return_type
    else
      raise error("Undefined function: #{name}")
    end
  end

  private def check_procedure_call(expression : ProcedureCall) : Type
    # Constructors for types are always uppercase 
    return check_constructor(expression) if expression.callee.name[0].ascii_uppercase?
    check_call(expression)
  end

  private def check_constructor(expression : ProcedureCall) : Type
    name = expression.callee.name
    type_definition = @env.type_definition(name) || raise error("Unknown type: #{name}")


    type_definition = type_definition.as(ProductTypeDefinition) # TODO will have to handle differently with union typedefs

    constructor_definition = type_definition.constructor
    generic_subs = {} of GenericTypeParameter => NamedType
    expression.arguments.each do |arg|
      assignment = arg.as?(VarReassignment) || raise error("Expected constructor expression, i.e. MyType(x = 0)")
      arg_name = assignment.variable_identifier.name
      field_type = type_definition.fields[arg_name]? || raise error("Undefined field name #{arg_name} in #{name} constructor")

      value_type = check_expression(assignment.value)

      # If generic look that its init value resolved type is consistent with other generics in the call
      # Resolve as we go
      if field_type.generic? 
        field_type = field_type.as(GenericTypeParameter)
        field_type = generic_subs[field_type]? || (generic_subs[field_type] = value_type.as(NamedType))
      end

      if field_type != value_type
        raise error("Field #{arg_name} expected to be #{field_type.to_s}, recieved #{value_type.to_s}")
      end
    end

    # Finally, apply any substitutions we inferred to the return type (if applicable)
    return generic_sub(
      constructor_definition.resolved_type.return_type,
      generic_subs
    )
  
  end

  private def generic_sub(type : Type, generic_subs : Hash(GenericTypeParameter, NamedType)) : NamedType
    if type.generic?
      case type
      when GenericTypeParameter
        type = generic_subs[type]? || raise error("Cannot infer type of #{type}'s generic return type")
      when NamedType
        type.type_arguments = type.type_arguments.map do |type_arg|
          generic_sub(type_arg, generic_subs).as(Type)
        end
      end
    end
    return type.as(NamedType)
  end

end