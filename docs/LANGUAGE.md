# G Language

G is a native, self-hosted systems programming language.

## File extension

G source files use the `.g` extension.

## Compiler

The compiler is GCM.

### Windows

`.g -> GCM -> x86-64 machine code -> PE32+ -> .exe`

### Linux

`.g -> GCM -> x86-64 machine code -> ELF64 -> executable`

## Core syntax

```g
fn main() {
    var x;
    x = 42;

    if (x > 10) {
        print("Hello from G\n");
    }

    return 0;
}
```

## Main language features

- `fn` functions
- `var` variables
- `if` / `else`
- `while`
- `break` / `continue`
- arrays and pointers
- strings
- command-line arguments
- file I/O
- native x86-64 code generation

## GitHub language detection

The `.g` extension is currently shared by existing GitHub Linguist languages such as GAP and G-code. The files under `linguist/` are included to prepare G for an upstream GitHub Linguist language submission.
