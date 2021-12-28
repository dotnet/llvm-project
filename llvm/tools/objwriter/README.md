# Native Object Writer library

This library exposes C APIs to emit ELF/Mach-O/PE object files.

The implementation is based on LLVM's assembler APIs - these are APIs intended to be consumed by assembly language compilers and are therefore close to the underlying object file formats. When in doubt, look at how the assemblers (e.g. llvm-ml in the tools directory of LLVM) use these APIs.
