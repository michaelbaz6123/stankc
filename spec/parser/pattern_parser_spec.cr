require "./spec_helper"
describe PatternParser do
  describe "#parse" do
    it "parses match expression" do
      ast = parse("match x then A => 0, B => 1 end;")
      ast.procedure.statements.first
      .as(ExpressionStatement).expression
      .should be_a(MatchExpression)
    end

    it "parses match expression with binding" do
      ast = parse("match x then Some(i = value) => i + 1, Nil => nil end;")
      variant_pattern = ast.procedure.statements.first
      .as(ExpressionStatement).expression
      .as(MatchExpression).branches.first.pattern
      .as(VariantPattern)
      variant_pattern.variant_name.should eq("Some")
      variant_pattern.field_patterns.first.pattern
      .should be_a(BindingPattern)
    end

    it "parses match expression with nested patterns" do
      ast = parse("match x then Some(Some(i = value) = value) => i + 1, Nil => nil end;")
    end

    it "parses wildcard matching" do
      ast = parse("match x then _ => x end;")
      ast.procedure.statements.first
      .as(ExpressionStatement).expression
      .as(MatchExpression).branches.first
      .pattern.should be_a(WildCardPattern)
    end

    it "parses if let statement" do
      ast = parse("if let Some(s = value) = x do s; end")
      ast.procedure.statements.first
      .should be_a(IfLetStatement)
    end
  end
end