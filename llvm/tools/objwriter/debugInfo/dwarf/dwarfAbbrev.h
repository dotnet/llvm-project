//===---- dwarfAbbrev.h -----------------------------------------*- C++ -*-===//
//
// dwarf abbreviations
//
// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
//
//===----------------------------------------------------------------------===//

#pragma once

#include "llvm/BinaryFormat/Dwarf.h"
#include "llvm/MC/MCObjectStreamer.h"

using namespace llvm;

namespace DwarfAbbrev {

enum DwarfAbbrev : uint16_t
{
  CompileUnit = 0x1,
  BaseType,
  EnumerationType,
  EnumerationTypeNoChildren,
  Enumerator1,
  Enumerator2,
  Enumerator4,
  Enumerator8,
  TypeDef,
  Subprogram,
  SubprogramNoChildren,
  SubprogramStatic,
  SubprogramStaticNoChildren,
  SubprogramSpec,
  SubprogramStaticSpec,
  SubprogramStaticNoChildrenSpec,
  Variable,
  VariableLoc,
  VariableStatic,
  FormalParameter,
  FormalParameterThis,
  FormalParameterLoc,
  FormalParameterThisLoc,
  FormalParameterSpec,
  FormalParameterThisSpec,
  ClassType,
  ClassTypeNoChildren,
  ClassTypeDecl,
  ClassMember,
  ClassMemberStatic,
  PointerType,
  ReferenceType,
  ArrayType,
  SubrangeType,
  ClassInheritance,
  LexicalBlock,
  TryBlock,
  CatchBlock,
  VoidType,
  VoidPointerType,
};

void Dump(MCObjectStreamer *Streamer, uint16_t DwarfVersion, unsigned TargetPointerSize);

}
