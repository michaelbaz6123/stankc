# Stank Language Specification



## 🔸 Language Design

### Typing
- Dynamically typed; runtime type checking.
- Single `None` value of type `None`.
- All types are capitalized (e.g., `Int`, `Array`, `Hash`, `Result`).

### Bindings and Variables
- `let` creates an immutable binding.
- `let var` creates a mutable variable.



## 🔸 Functions and Procedures with Results and Errors

### Functions
- `func name : args => expr end`
- Pure: no side effects allowed. Must return a value by default.
- Use `func?` for returning `Option<V>`
- Use `func?:` for returning `Result<Ok(V), Err(...)>`.

### Procedures
- `proc name : args do ... end`
- May perform side effects.
- Implicit return: `Result<Ok, Err(...)>`.
- No return values except success/failure (`Ok()` or `Err(...)`).

### Result and Option
- `Option<T>` is defined to be either `V` or `Nil`
- `Result<Ok(T?), Err(String?, Int?)>`
- Supports syntactic sugar: `?` to propagate `Err`.
- `Err` can contain to optional wrapped values:
    - `Err(message?, code?)`



## 🔸 Modules and Structs

### Modules
- Declared using `module MyModule`.
- Files may define multiple modules.
- Modules can be nested.
- Each file may optionally define a `main` procedure.

### Structs
```
struct MyStruct has
    a : Int,
    b : String,
    c : Char
end
```
- Fields are dynamically typed. 
- Struct `has` its fields.



## 🔸 Types

### Atomic Types
- `Int`, `I32`, `I64`, `I128`
- `Float`
- `Char`
- `Bool`
- `None`
- `String`

### Compound Types
- `Array`: dynamic, homogeneous
- `Tuple`: fixed-size, heterogeneous
- `Hash`: unified type for map and set
  - `h[key] = value` for map behavior
  - `h << value` for set behavior
- `Result`, `Option` (see above)

> All compound types are dynamically typed containers unless specified otherwise.

### Casting Operators

1. `as` 

- Perform an explicit type cast from one type to another.
    - Syntax: `<expression> as <Type>`
    - Attempts to cast the value of `<expression>` to the specified `<Type>`.
    - Returns `Ok(value)` if the cast succeeds.
    - Returns `Err("cast error message")` if the cast fails.
    ```
    let var x = someValue as Int
    match x {
      Ok(v) => print(v),
      Err(e) => print("Cast failed: " + e)
    }
    ```

2. `as?` Operator

- Convenience operator for casting with automatic error propagation.
    - Attempts to cast `<expression>` to `<Type>`.
    - On success, returns the cast value directly.
    - On failure, immediately returns the `Err` from the current function/procedure, propagating the error.
    ```
    fn parseInt : val =>
        let number = val as? Int
        number + 1
    end
    ```

Notes:

- Both operators perform runtime checks since the language is dynamically typed.
- `as?` implicitly uses the language’s error propagation mechanism (`?` operator equivalent).
- Neither operator modifies the original value; they return new casted values wrapped in `Result` or directly on success.



## 🔸 Syntax Overview

- **Statements**: Must end with semicolon `;`
- **Expressions**: No semicolon
- **Blocks**: Use `do ... end`
- **Function Arguments**: Supports both:
  - Colon style: `fn name : a b =>`
  - Paren style: `fn name(a, b) =>`



## 🔸 Control Flow

### Conditional

Control Flow — Conditionals

- `if ... then ... else ... end`
  - Pure conditional expression.
  - Used inside functions (`fn`).
  - Returns a value.
  - `then` indicates the start of the pure expression branch.
  - `else` branch required for completeness.
  - Example:
    ```
    fn abs : x =>
        if x < 0 then -x else x end

    fn foo : y =>
        if y == 0 then "zero" elif 
    ```

- `if ... do ... else ... end`
  - Procedural conditional block.
  - Used inside procedures (`pr`).
  - Allows side effects inside branches.
  - `do` indicates the start of an impure statement block.
  - `else` optional.
  - Example:
    ```
    pr printSign : x do
        if x < 0 do
            print("negative")
        else
            print("non-negative")
        end
    end
    ```


