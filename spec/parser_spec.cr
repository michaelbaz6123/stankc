require "./spec_helper"

def parse(source) : AST
  begin
    return Parser.new(source).parse.as(AST)
  rescue pe : ParseError
    raise "parse failed with #{pe.message}"
  end
end

describe Parser do

  describe "#parse" do  
    it "returns an AST with procedure at top level" do
      ast = parse("")
      ast.should be_a AST
      ast.procedure.should be_a Procedure
    end

    it "parses bindings" do
      ast = parse("let x : String = \"Hello\";")

      stmt = ast.procedure.statements.first
      stmt.should be_a Binding

      binding = stmt.as(Binding)
      typed_name = binding.typed_name
      name = typed_name.name.raw
      
      name.should eq("x")
      value = binding.value
      value.should be_a Literal
    end

    it "parses variable declaration" do
      ast = parse("var x : I32 = 0;")

      stmt = ast.procedure.statements.first
      stmt.should be_a VarDeclaration
      assignment = stmt.as(VarDeclaration)
      typed_name = assignment.typed_name
      name = typed_name.name.raw
      name.should eq("x")
      value = assignment.value
      value.should be_a Literal
    end

    it "parses field access of variable in expression" do
      ast = parse("foo.bar.baz;")
      stmt = ast.procedure.statements.first.as(ExpressionStatement)

      expression = stmt.expression.as(VariableExpression)
      names = expression.variable.names
      names[0].raw.should eq("foo")
      names[1].raw.should eq("bar")
      names[2].raw.should eq("baz")
    end

    it "parses if expressions" do
      ast = parse("let x : I32 = if 1 < 2 then 3 else 4 end;")

      stmt = ast.procedure.statements.first.as(Binding)
      expr = stmt.value.as(IfExpression)

      expr.branches.size.should eq(1)
      condition = expr.branches.first.condition
      condition.should be_a Expression
      
      binary_expression = condition.as(BinaryExpression)
      
      binary_expression.left.should be_a Literal
      binary_expression.operator.should be_a TokenType
      binary_expression.right.should be_a Literal

      expr.branches.first.body.should be_a Literal
      expr.else_body.should be_a Literal

    end

    it "parses struct declaration" do
      ast = parse("struct MyStruct has x : I32, y : String, z : Bool end")
      struct_declaration = ast.procedure.statements.first.as(StructDeclaration)
      struct_declaration.name.raw.should eq("MyStruct")
      struct_declaration.fields.size.should eq(3)
    end

    it "parses while loops" do
      ast = parse("while true do print(0); end");
      stmt = ast.procedure.statements.first.as(Statement)
      stmt.should be_a(WhileLoop)
      while_loop = stmt.as(WhileLoop)
      while_loop.condition.should be_a(Literal)
      while_loop.body.should be_a(Procedure)
      body = while_loop.body.as(Procedure)
      body.statements.size.should eq(1)
    end

    it "parses procedure calls" do
      ast = parse("foo(x, y, z);")
      stmt = ast.procedure.statements.first.as(ExpressionStatement)
      proc_call = stmt.expression.as(ProcedureCall)
      args = proc_call.args.args.as(Array(Expression))
      args.size.should eq(3)
      proc_name = proc_call.callee.as(Variable)
      proc_name.names
    end

    it "parses function calls" do
      ast = parse("foo $ (x, y, z);")
      stmt = ast.procedure.statements.first.as(ExpressionStatement)
      proc_call = stmt.expression.as(FunctionCall)
      args = proc_call.args.args.as(Array(Expression))
      args.size.should eq(3)
      proc_name = proc_call.callee.as(Variable)
      proc_name.names
    end

    it "parses complex expressions" do
      ast = parse("foo(if x > y then 0 else bar.baz(1, z) end, \"hello\");")
      stmt = ast.procedure.statements.first.as(ExpressionStatement)
      procedure_call = stmt.expression.as(ProcedureCall)
      args = procedure_call.args.args.as(Array(Expression))
      args.size.should eq(2)
      args.first.should be_a IfExpression
    end
  end

  
end