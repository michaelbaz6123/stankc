# 🦨 Stank Lang

## ➡️ Overview, Philosophy
In Stank, we separate what a program computes from what it does.

- Use `fn` for pure computations.

- Use `proc` for impure actions.

A `proc` can succeed or fail, but it cannot return a value.
If a procedure needs to communicate a result, it should do so by:

- Mutating a variable

- Calling another function to compute the value

## ➡️ Comments
- Single-line comments begin with `#`
- Block comments not yet supported

## ➡️ Typing
- Every value has a type.
- All types are capitalized (e.g., `I32`, `Array`, `Hash`).
- Atomic types:
  - `I32`, `I64`      # 1, 12, 34, etc.
  - `F32`, `F64`      # 12.3, 94.421, etc.
  - `String`, `Char`  # "Hello", 'c', etc.
  - `Bool`            # true, false
  - `Nil`             # nil


## ➡️ Declaring Types
### Union Types
- Declared as `type MyType is OtherType [ | AnotherType] end`
```
type I32OrString is 
  I32 | String 
end

# Works as an alias too!
type MagicNumber is I32 end
```
- All unions are structural, and field access on a union is valid only if all branches have the field.
### Product Types
- Declared as `type MyType has field : SomeType end`
```
type Point has
  x : I32,
  y : I32
end

let point : Point = Point(x = 10, y = 13);
print(point.x);
print(point.y);
```

## ➡️ Generic Types
- Types can be generic over other types using angle brackets to declare and parentheses to instantiate.
```
type Point<T> has
  x : T,
  y : T
end

type MaybePoint<T> is Point(T) | Nil
```
- For example, the primitive `Maybe<T>`, used to represent optional values:
  ```
  type Maybe<T> is T | Nil end
  ```

## ➡️ Literals & Built-in Values
- `true`, `false` are `Bool`
- `nil` is the only value of type `Nil`
- Numbers default to integer unless `.` present in literal.


## ➡️ Bindings and Variables
- `let x : I32 = 10;` binds `x` as `I32` to `10` (immutable). Must always initialize.
- `var y : I32 = 23;` declares a mutable variable `y` as `I32` with value `23`.
  - `var z : I32;` is also valid to declare without initializing.
- Type annotations required, type inference not implemented yet.

## ➡️ Collective Types
- All collection types can be mutable or immutable.
- `Array(T)`: dynamic sizing, homogeneous on `T`.
```
var my_array : Array(I32) = [1, 2, 3, 4, 5]; # Array literal
my_array[0] = 12;
print(my_array[2]) # 3
print(my_array[0]) # 12
```
- `Tuple(FirstType, SecondType, ...)`: fixed-size, heterogeneous over listed `FirstType, SecondType, ...`
```
var my_tuple : Tuple(I32, String, Bool) = (10, "Hello", true); # Tuple literal
print(my_tuple[1]) # "Hello"

```
- `Hash(K, V)`: maps keys of `K` to `V`
```
var my_hash : Hash(String, I32) = { "foo" => 0 } # Hash literal
print(my_hash["foo"]) # 0
my_hash["bar"] = 34
print(my_hash["bar"]) # 34

```

## ➡️ Functions and Procedures 

  ### The Difference and Syntax
  - **Functions** use `=> ... end` to declare an expression a function evaluates.
  - **Expressions** exist to be evaluated in context of function bodies, conditional expressions, etc.
  - **Procedures** use `do ... end` to declare a list of statements that perform side effects.
  - **Statements** must end with semicolon `;`


  ### Functions
  - Pure: no side effects allowed. Defined to be a single expression.
  - "Applicator" `$` is required after function name in declaration and when calling.
  ```
  fn foo $ 
  (a : I32, b : I32, c : I32) : I32 =>
      a + b + c
  end

  x = foo$(a, b, c);

  # Parentheses optional for no arg functions
  fn bar $ => "something" end

  print(bar$)
  ```

 ### Procedures
  ```
  proc my_proc([<name> : <Type>, ...]) do 
    ... 
  end 

  my_proc();
  ```
  #### The `Result` Type and `raise`ing Errors
  - Procedures always implicitly return: `Result`
  - Procedures either finish with `Ok` or `Err(message : String)`
  ```
  type Result is Ok | Err end
  type Ok is Nil end
  type Err has message : String end
  ```
  - Use `raise msg;` to exit procedure and implicitly return `Err(message = msg)`
  ```
  proc my_proc(x : I32) do 
    if x > 0
      print(x);
    else
      raise "Error occurred";
    end
  end 

  result = my_proc(-1);
  print(result.message) # Error occurred
  ```

  ### Generics
  - Both functions and procedures can be generic over more than one type.
    ```
    fn foo<T> $ 
    (p : Point(T)) : T => 
      p.x 
    end

    proc bar<T>(x : T) do
      print(x.field) # Type inference will check if x's type has field at call
    end
    ```

## 🔸 Procedural Control Flow
- `if ... do ... else ... end`
  - Procedural conditional block.
  - Used inside procedures (`proc`).
  - Allows side effects inside branches.
  - `do` indicates the start of an impure procedure block.
  - `else` optional.
  - Example:
    ```
    proc printSign(x : I32) do
        if x < 0 do
            print("negative");
        else
            print("non-negative");
        end
    end
    ```
- `while ... do ... end`
  - Loop a procedure while condition is true.
  - Same as `if do`, procedure can (and should) have side effects.
  - Example:
    ```
    ...
      while x > 0 do
        print(x);
        x -= 1;
      end
    ```

## ➡️ Expressions

### Atomic Operators
- Arithmetic
  - Addition, subtraction, multiplication, division, and integer division.
    ```
    let a : I32 = x + y;
    let b : I32 = x - y;
    let c : I32 = x * y;
    let d : F32 = x / y;
    let e : I32 = x // y;
    let f : I32 = x % y;
    ```
- Boolean Logic
  - And, or, not
    ```
    let x : Bool = true && false; # false
    let y : Bool = true || false; # true
    let z : Bool = !false;        # true
    ```
- Bitwise Logic
  - Bitwise and, bitwise or, bitwise xor
    ```
    let x : I32 = 12 & 8;   # 8
    let y : I32 = 12 | 32;  # 44
    let z : I32 = 31 ^ 12;  # 19
    ```
- Reassignment operators
  - For all arithmetic (except modulo), boolean, and bitwise binary operators.
    ```
    x += 1; y -= 2; y *= 3; z /= 4; p //= 5;
    
    a &&= p; b ||= q; 

    x &= 2; y |= 4; z ^= 8
    ```

- `if ... then ... else ... end`
  - Pure conditional expression.
  - Used inside expressions, functions.
  - Evaluates to something.
  - `then` indicates the start of the pure expression branch.
  - `else` branch optional, returns `Maybe<T>` if not included
  - Example:
    ```
    fn abs $ (x : I32) : I32 =>
      if x < 0 then -x else x end
    end

    fn foo $ (y : I32) : String? =>
      if y == 0 then "zero" end
    end 
    ```

## ➡️ Modules
- Declared using `module MyModule has ... end`.
- Files may define multiple modules.
- Each file may optionally define a `main` procedure declared on outermost scope.
- Work like namespaces in other languages, use `SomeModule::symbol` to access a definition inside the module.
```
module MyModule has
  fn foo $ (x : I32): I32 =>
    x + 1
  end
end

let module_result : I32 = MyModule::foo$(12)
```

## ➡️ Program Structure
- A single `.stank` program can be:
  - A **program** with `proc main()` that compiles to an executable.
    - Optional `proc main(args : Array(String))` for command line arguments.
  - A **library** that declares a single `module`


### Importing Modules
my_library.stank:
```
module MyModule has
  proc foo() do
    print("Hello world!");
  end

  fn bar $ (x : I32) => I32
    x + 1
  end
end
```
my_program.stank:
```
import MyModule from "my_library";

proc main() do
  MyModule::foo();          # "Hello, world!"
  print(MyModule::bar(12)); # 12
end
```

## ➡️ Memory, How Stank is Implemented
- Stank transpiles to C code that is then compiled into machine code. 
- All values in Stank are allocated on the heap, memory is managed via Boehm-Demers-Weiser Garbage Collector.


## ➡️ Coming, but not implemented yet
- Pattern matching
- Type inference
- Type constraints on generics.