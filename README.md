# Bcs24-Compiler

Implementation of a compiler for the Bcs24 programming language using Flex, Bison, and C.

## Requirements

The following tools are required to build the compiler:

- GCC
- Flex
- Bison
- Make

## Project Structure

- `lexer.l` — Flex lexer specification
- `parser.y` — Bison parser specification
- `parser.tab.c` — Generated parser source file
- `parser.tab.h` — Generated parser header file containing token definitions
- `lex.yy.c` — Generated lexer source file
- `valid_1.bcs`, `valid_2.bcs` — Valid Bcs24 test programs
- `invalid_1.bcs`, `invalid_2.bcs`, `invalid_3.bcs` — Invalid Bcs24 test programs
- `Makefile` — Automates the build process

## Building the Compiler

Run the following command from the project directory:

```bash
make