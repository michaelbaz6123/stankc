# Stank Language Development Roadmap

## Lexer / Parser
- Completed for most part



## Type Checker
- Type inference rules:
  - Coerce numbers into `Float` if any `Float`s present in expression for:
    - `+`, `-`, `*`,
  - `//` and `%` only defined for `Int` 
  - `/` always coerces inputs to `Float`, returns `Float` of course

## Semantic Analysis