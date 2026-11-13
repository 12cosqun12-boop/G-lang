# G Programming Language 1.0

G is a small self-hosted native systems programming language with direct x86-64 executable generation.

## Platforms

- Windows x86-64: PE32+ executable output
- Linux x86-64: ELF64 executable output

No LLVM is required. The bundled compilers generate native machine code and package it directly as PE32+ or ELF64.

## Quick start — Windows

PowerShell:

```powershell
.\g.cmd examples\hello_cosqun.g hello.exe
.\hello.exe
```

Expected output:

```text
Hello Cosqun
```

## Quick start — Linux

```bash
chmod +x ./g ./bin/linux-x86_64/g
./g examples/hello_cosqun.g hello
./hello
```

Expected output:

```text
Hello Cosqun
```

## G Tasks example

Windows:

```powershell
.\g.cmd examples\g_tasks.g g_tasks.exe
.\g_tasks.exe clear
.\g_tasks.exe add My first G app
.\g_tasks.exe list
.\g_tasks.exe stats
```

Linux:

```bash
./g examples/g_tasks.g g_tasks
./g_tasks clear
./g_tasks add My first G app
./g_tasks list
./g_tasks stats
```

## Compiler pipeline

```text
.g source
  -> lexer/parser/codegen
  -> internal x86-64 assembler/encoder
  -> native machine code
  -> PE32+ (Windows) or ELF64 (Linux)
  -> executable
```

## Repository layout

```text
bin/
  windows-x86_64/g.exe
  linux-x86_64/g
src/
  windows/
  linux/
examples/
tests/
scripts/
g.cmd
g
```

## Tests

Linux:

```bash
./scripts/run_tests_linux.sh
```

Windows PowerShell:

```powershell
.\scripts\run_tests_windows.ps1
```

## Current scope

G 1.0 focuses on native x86-64 command-line applications. The compiler includes its own lexer, parser, code generator, assembler/encoder and executable writer. Windows uses PE32+ and Linux uses ELF64.

GUI libraries, additional CPU architectures and additional operating systems can be added in later versions.

## License

No open-source license has been selected yet. Add a LICENSE file before public release if you want others to have explicit permission to modify and redistribute the project.
