# Stank Language Development Roadmap

## Lexer / Parser
- Completed for most part



## Type Checker
- Arithmetic type inference:
  - Coerce numbers into `Float` if any `Float`s present in expression for:
    - `+`, `-`, `*`,
  - `//` and `%` only defined for `Int` 
  - `/` always coerces inputs to `Float`, returns `Float` of course
- Tuple type handling


## Semantic Analysis