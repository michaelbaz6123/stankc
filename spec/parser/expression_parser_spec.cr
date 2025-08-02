require "./spec_helper"
describe ExpressionParser do
  describe "#parse" do

    it "parses procedure calls" do
      ast = parse("foo(x, y, z);")
      stmt = ast.procedure.statements.first.as(ExpressionStatement)
      proc_call = stmt.expression.as(ProcedureCall)
      args = proc_call.arguments.as(Array(Expression))
      args.size.should eq(3)
      proc_id = proc_call.callee.as(VariableIdentifier)
      proc_id.name.should eq("foo")
    end

    it "parses function calls" do
      ast = parse("foo $ (x, y, z);")
      stmt = ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .should be_a(FunctionCall)
    end

    it "parses function calls with no args without ()" do
      ast = parse("foo$;")
      ast.procedure.statements.first
        .as(ExpressionStatement).expression
        .as(FunctionCall)
        .arguments.size.should eq(0)
    end

    it "parses complex expressions" do
      ast = parse("foo(if x > y then 0 else bar.baz(1, z) end, \"hello\");")
      stmt = ast.procedure.statements.first.as(ExpressionStatement)
      procedure_call = stmt.expression.as(ProcedureCall)
      args = procedure_call.arguments.as(Array(Expression))
      args.size.should eq(2)
      args.first.should be_a IfExpression
    end

    it "parses if expressions" do
      ast = parse("let x = if 1 < 2 then 3 else 4 end;")

      stmt = ast.procedure.statements.first.as(Binding)
      expr = stmt.value.as(IfExpression)

      expr.branches.size.should eq(1)
      expr.branches.first.body.should be_a Literal
      expr.else_body.should be_a Literal

    end

    it "parses field access of variable in expression" do
      ast = parse("foo.bar.baz;")
      stmt = ast.procedure.statements.first.as(ExpressionStatement)

      expression = stmt.expression.as(VariableExpression)
      name = expression.variable.name
      accessor_names = expression.variable.accessor_names
      name.should eq("foo")
      accessor_names[0].should eq("bar")
      accessor_names[1].should eq("baz")
    end

  end
end