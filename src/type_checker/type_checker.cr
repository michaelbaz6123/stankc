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
      type_arguments << parse_type_identifier(id, generics)
    end

    return NamedType.new(name) if type_arguments.empty?

    type_def = @env.type_definition(name) || raise error("Undefined type: #{name}")
    case type_def
    when ProductTypeDefinition
      ProductType.new(name, type_arguments)
    when UnionTypeDefinition
      UnionType.new(name, type_arguments)
    else
      raise error("Expected product/union type for type arguments, but type is not defined as so: #{name}")
    end
  end

  private def is_assignable?(actual_type : Type, expected_type : Type, generic_subs : Hash(GenericTypeParameter, NamedType) = {} of GenericTypeParameter => NamedType) : Bool
    pp actual_type, expected_type
    # 1 Regular equality
    return true if actual_type == expected_type

    # 2 Atomic promotion
    if actual_type.is_a?(NamedType) && expected_type.is_a?(NamedType)
      return true if actual_type.name == "Int" && expected_type.name == "Float"
    end

    # 3 Expected is UnionType: actual must be assignable to at least one variant
    if expected_type.is_a?(UnionType)
      type_def = @env.type_definition(expected_type.name).as?(UnionTypeDefinition) || raise error("Expected union type")
      return type_def.variants.any? do |variant|
        variant_with_subs = generic_sub(variant, generic_subs)
        is_assignable?(actual_type, variant_with_subs, generic_subs)
      end
    end
    
    # 4 Union on actual: all variants must be assignable to expected
    if actual_type.is_a?(UnionType)
      return actual_type.variants.all? { |v| is_assignable?(v, expected_type) }
    end

    # 5. Product types: names must match, and all fields/args assignable
    if actual_type.is_a?(ProductType) && expected_type.is_a?(ProductType)
      return false unless actual_type.name == expected_type.name
      # Assuming field order or names match exactly
      return false unless actual_type.fields.size == expected_type.fields.size

      return actual_type.fields.zip(expected_type.fields).all? do |at, et|
        is_assignable?(at, et)
      end
    end

    return false

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
