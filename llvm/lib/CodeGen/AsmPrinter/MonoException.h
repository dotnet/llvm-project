//===---*- mode: c++; indent-tabs-mode: nil -*----------------------------===//
//===-- MonoException.h - Dwarf Exception Framework -----------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//

#ifndef LLVM_LIB_CODEGEN_ASMPRINTER_MONOEXCEPTION_H
#define LLVM_LIB_CODEGEN_ASMPRINTER_MONOEXCEPTION_H

#include "EHStreamer.h"
#include "llvm/CodeGen/AsmPrinter.h"

namespace llvm {

class TargetRegisterInfo;

// TODO: we need to use DebugHandlerBase and addDebugHandler, so that beginInstruction is called
// context https://github.com/llvm/llvm-project/pull/96785
class MonoException : public EHStreamer {
public:
  MonoException(AsmPrinter *A, bool disableGNUEH);
  virtual ~MonoException();

  void endModule() override;

  void beginFunction(const MachineFunction *MF) override;

  void endFunction(const MachineFunction *) override;

private:

  struct MonoCallSiteEntry {
    // The 'try-range' is BeginLabel .. EndLabel.
    MCSymbol *BeginLabel; // zero indicates the start of the function.
    MCSymbol *EndLabel;   // zero indicates the end of the function.

    // The landing pad starts at PadLabel.
    MCSymbol *PadLabel;   // zero indicates that there is no landing pad.
    int TypeID;
  };

  // Per-function EH info
  struct EHInfo {
    int FunctionNumber, MonoMethodIdx;
	MCSymbol *BeginSym, *EndSym, *FDESym;
	std::vector<MCSymbol*> EHLabels;
    std::vector<MCCFIInstruction> Instructions;
    std::vector<MonoCallSiteEntry> CallSites;
    std::vector<const GlobalValue *> TypeInfos;
    std::vector<LandingPadInfo> PadInfos;
    int FrameReg;
    int ThisOffset;
    bool HasLandingPads;

    EHInfo() {
      FunctionNumber = 0;
      MonoMethodIdx = 0;
      BeginSym = nullptr;
      EndSym = nullptr;
      FrameReg = -1;
      ThisOffset = 0;
      HasLandingPads = 0;
    }
  };

  void PrepareMonoLSDA(EHInfo *info);
  void EmitMonoLSDA(const EHInfo *info);
  void EmitFnStart();
  void EmitFnEnd();

  std::vector<MCSymbol*> EHLabels;
  std::vector<EHInfo> Frames;
  StringMap<int> FuncIndexes;
  const TargetRegisterInfo *RI;
  bool DisableGNUEH;
};
} // End of namespace llvm

#endif

