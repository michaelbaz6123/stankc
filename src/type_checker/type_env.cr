class TypeEnv
  @scopes : Array(Hash(String, Type))

  def initialize
    @scopes = [Hash(String, Type).new]
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
end
