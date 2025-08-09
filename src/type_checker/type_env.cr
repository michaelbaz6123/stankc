class TypeEnvironment
  # variables, bindings
  @scopes : Array(Hash(String, Type))
  @typedefs : Hash(String, TypeDefinition)
  @funcdefs : Hash(String, FunctionDefinition)

  def initialize
    @scopes = [Hash(String, Type).new]
    @typedefs = Hash(String, TypeDefinition).new
    @funcdefs = Hash(String, FunctionDefinition).new
  end

  def enter_scope
    @scopes.push(Hash(String, Type).new)
  end

  def exit_scope
    @scopes.pop
  end

  def declare(name : String, type : Type)
    @scopes.last[name] = type
  end

  def lookup(name : String) : Type?
    @scopes.reverse_each do |scope|
      return scope[name]? if scope.has_key?(name)
    end
    nil
  end

  def define_type(name : String, definition : TypeDefinition)
    @typedefs[name] = definition
  end

  def type_definition(name) : TypeDefinition?
    @typedefs[name]?
  end

  def define_function(name : String, definition : FunctionDefinition)
    @funcdefs[name] = definition
  end

  def function_definition(name) : FunctionDefinition?
    @funcdefs[name]?
  end
end
