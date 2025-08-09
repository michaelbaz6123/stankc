require "./type_env"
require "./type_error"
require "./type"
require "./definition"
require "./declaration_type_checker"
require "./expression_type_checker"

class TypeChecker
  include DeclarationTypeChecker
  include ExpressionTypeChecker

  @env : TypeEnvironment

  def initialize
    @env = TypeEnvironment.new
    ["Int", "Float", "Bool", "Char", "Nil", "String"].each do |name|
      @env.define_type(name, AtomicTypeDefinition.new(name))
    end
  end

  def check(ast : AST)
    check_procedure(ast.procedure)
  end

  private def check_procedure(procedure : Procedure)
    procedure.statements.each do |stmt|
      check_statement(stmt)
    end
  end

  private def check_statement(stmt : Statement)
    case stmt
    when Binding
      check_binding(stmt)
    when ProductTypeDeclaration
      check_product_type_declaration(stmt)
    when UnionTypeDeclaration
      check_union_type_declaration(stmt)
    when FunctionDeclaration
      check_function_declaration(stmt)
    when ProcedureDeclaration
      check_procedure_declaration(stmt)
    else
      raise error("Unsupported statement: #{stmt.class}")
    end
  end

  # AST type identifier from user type annotations to resolved type
  private def parse_type_identifier(type_identifier : TypeIdentifier, generics : Array(String) = [] of String) : Type
    name = ensure_type_name(type_identifier.name)

    if generics.includes?(name)
      raise error("Cannot pass type parameters to generic #{name}") unless type_identifier.inner_type_ids.empty?
      return GenericTypeParameter.new(name)
    end

    type_arguments = [] of Type
    type_identifier.inner_type_ids.each do |id|
      type_arguments << parse_type_identifier(id)
    end
    
    NamedType.new(name, type_arguments)
  end

  private def is_numeric_type(type : Type) : Bool
    raw = type.name
    raw == "Int" || raw == "Float"
  end

  private def ensure_var_name(name : String) : String
    raise error ("Invalid binding/variable name : #{name}, must start lowercase") unless name[0].ascii_lowercase?
    name
  end

  private def ensure_type_name(name : String) : String
    raise error ("Invalid type name : #{name}, must start uppercase") unless name[0].ascii_uppercase?
    name
  end

  private def error(message : String) : TypeError
    TypeError.new(message, 0, 0)
  end
end
