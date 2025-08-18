module DeclarationTypeChecker

  private def check_binding(binding : Binding)
    name = ensure_var_name(binding.name)
    maybe_type_id = binding.type_identifier
    value_type = check_expression(binding.value)
    resolved_type = value_type
    if type_id = maybe_type_id
      annotation_type = parse_type_identifier(type_id)
      unless is_assignable?(value_type, annotation_type)
        raise error("Type mismatch in binding '#{name}': expected #{annotation_type.to_s}, got #{value_type.to_s}")
      end
      resolved_type = annotation_type
    end

    binding.resolved_type = resolved_type

    @env.declare(name, resolved_type)
  end

  private def check_function_declaration(declaration : FunctionDeclaration)
    name = declaration.name
    return_type = check_expression(declaration.body)

    # check type annotation is consistent with expression body
    if expected_type_id = declaration.return_type_identifier
      expected_type = parse_type_identifier(expected_type_id)
      unless expected_type == return_type
        raise error("#{declaration.name}: Expected #{expected_type.to_s} but received #{return_type.to_s}")
      end
    end

    parameter_types = declaration.params.map  do | param | 
      parse_type_identifier(param.type_identifier).as(Type) 
    end
    generics = declaration.generics.map do | generic_name |
      GenericTypeParameter.new(generic_name)
    end
    function_type = FunctionType.new(parameter_types, return_type)
    declaration.resolved_type = function_type
    FunctionDefinition.new(name, function_type)
  end

  private def check_procedure_declaration(declaration : ProcedureDeclaration)
    parameter_types = [] of Type

    @env.enter_scope
    declaration.params.each do | parameter |
      parameter_type = parse_type_identifier(parameter.type_identifier)
      parameter_types << parameter_type
      @env.declare(parameter.name, parameter_type)
    end

    check_procedure(declaration.body)
    @env.exit_scope

    result_type = UnionType.new("Result", [
                      ProductType.new("Err", [NamedType.new("String").as(Type)]).as(Type), 
                      NamedType.new("Ok").as(Type)
                  ])
    procedure_type = FunctionType.new(parameter_types, result_type)
    declaration.resolved_type = result_type
    @env.declare(declaration.name, procedure_type)
  end

  private def check_product_type_declaration(declaration : ProductTypeDeclaration)
    name = ensure_type_name(declaration.name)
    fields = declaration.fields.to_h do | field |
      field_name = ensure_var_name(field.name)
      field_type = parse_type_identifier(field.type_identifier, declaration.generics).as(Type)
      { field_name,  field_type }
    end
    
    parameter_types = fields.values

    constructor_parameters = declaration.generics.map do |name| 
      GenericTypeParameter.new(name).as(Type) 
    end
    type = ProductType.new(name, constructor_parameters)
    constructor_type = FunctionType.new(parameter_types, type)
    constructor = ConstructorDefinition.new(name, constructor_type)

    definition = ProductTypeDefinition.new(name, fields, constructor)
    @env.define_type(name, definition)
  end

  private def check_union_type_declaration(declaration : UnionTypeDeclaration)
    # TODO still does not resolve when instantiating
    name = ensure_type_name(declaration.name)
    variants = declaration.variants.map do | variant_type_id |
      parse_type_identifier(variant_type_id, declaration.generics)
    end

    definition = UnionTypeDefinition.new(name, variants)
    variants.each do |variant_type|
      variant_type_definition = @env.type_definition(variant_type.name) || raise error("Undefined type in union: #{variant_type.name}")
    end
    @env.define_type(name, definition)
  end

end