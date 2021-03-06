//===--------- LoopSimplifyCFG.cpp - Loop CFG Simplification Pass ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the Loop SimplifyCFG Pass. This pass is responsible for
// basic loop CFG cleanup, primarily to assist other loop passes. If you
// encounter a noncanonical CFG construct that causes another loop pass to
// perform suboptimally, this is the place to fix it up.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Scalar/LoopSimplifyCFG.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/Analysis/MemorySSA.h"
#include "llvm/Analysis/MemorySSAUpdater.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/ScalarEvolutionAliasAnalysis.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/DomTreeUpdater.h"
#include "llvm/IR/Dominators.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Scalar/LoopPassManager.h"
#include "llvm/Transforms/Utils.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
using namespace llvm;

#define DEBUG_TYPE "loop-simplifycfg"

static bool mergeBlocksIntoPredecessors(Loop &L, DominatorTree &DT,
                                        LoopInfo &LI, MemorySSAUpdater *MSSAU) {
  bool Changed = false;
  DomTreeUpdater DTU(DT, DomTreeUpdater::UpdateStrategy::Eager);
  // Copy blocks into a temporary array to avoid iterator invalidation issues
  // as we remove them.
  SmallVector<WeakTrackingVH, 16> Blocks(L.blocks());

  for (auto &Block : Blocks) {
    // Attempt to merge blocks in the trivial case. Don't modify blocks which
    // belong to other loops.
    BasicBlock *Succ = cast_or_null<BasicBlock>(Block);
    if (!Succ)
      continue;

    BasicBlock *Pred = Succ->getSinglePredecessor();
    if (!Pred || !Pred->getSingleSuccessor() || LI.getLoopFor(Pred) != &L)
      continue;

    // Merge Succ into Pred and delete it.
    MergeBlockIntoPredecessor(Succ, &DTU, &LI, MSSAU);

    Changed = true;
  }

  return Changed;
}

static bool simplifyLoopCFG(Loop &L, DominatorTree &DT, LoopInfo &LI,
                            ScalarEvolution &SE, MemorySSAUpdater *MSSAU) {
  bool Changed = false;

  // Eliminate unconditional branches by merging blocks into their predecessors.
  Changed |= mergeBlocksIntoPredecessors(L, DT, LI, MSSAU);

  if (Changed)
    SE.forgetTopmostLoop(&L);

  return Changed;
}

PreservedAnalyses LoopSimplifyCFGPass::run(Loop &L, LoopAnalysisManager &AM,
                                           LoopStandardAnalysisResults &AR,
                                           LPMUpdater &) {
  Optional<MemorySSAUpdater> MSSAU;
  if (EnableMSSALoopDependency && AR.MSSA)
    MSSAU = MemorySSAUpdater(AR.MSSA);
  if (!simplifyLoopCFG(L, AR.DT, AR.LI, AR.SE,
                       MSSAU.hasValue() ? MSSAU.getPointer() : nullptr))
    return PreservedAnalyses::all();

  return getLoopPassPreservedAnalyses();
}

namespace {
class LoopSimplifyCFGLegacyPass : public LoopPass {
public:
  static char ID; // Pass ID, replacement for typeid
  LoopSimplifyCFGLegacyPass() : LoopPass(ID) {
    initializeLoopSimplifyCFGLegacyPassPass(*PassRegistry::getPassRegistry());
  }

  bool runOnLoop(Loop *L, LPPassManager &) override {
    if (skipLoop(L))
      return false;

    DominatorTree &DT = getAnalysis<DominatorTreeWrapperPass>().getDomTree();
    LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    ScalarEvolution &SE = getAnalysis<ScalarEvolutionWrapperPass>().getSE();
    Optional<MemorySSAUpdater> MSSAU;
    if (EnableMSSALoopDependency) {
      MemorySSA *MSSA = &getAnalysis<MemorySSAWrapperPass>().getMSSA();
      MSSAU = MemorySSAUpdater(MSSA);
      if (VerifyMemorySSA)
        MSSA->verifyMemorySSA();
    }
    return simplifyLoopCFG(*L, DT, LI, SE,
                           MSSAU.hasValue() ? MSSAU.getPointer() : nullptr);
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    if (EnableMSSALoopDependency) {
      AU.addRequired<MemorySSAWrapperPass>();
      AU.addPreserved<MemorySSAWrapperPass>();
    }
    AU.addPreserved<DependenceAnalysisWrapperPass>();
    getLoopAnalysisUsage(AU);
  }
};
}

char LoopSimplifyCFGLegacyPass::ID = 0;
INITIALIZE_PASS_BEGIN(LoopSimplifyCFGLegacyPass, "loop-simplifycfg",
                      "Simplify loop CFG", false, false)
INITIALIZE_PASS_DEPENDENCY(LoopPass)
INITIALIZE_PASS_DEPENDENCY(MemorySSAWrapperPass)
INITIALIZE_PASS_END(LoopSimplifyCFGLegacyPass, "loop-simplifycfg",
                    "Simplify loop CFG", false, false)

Pass *llvm::createLoopSimplifyCFGPass() {
  return new LoopSimplifyCFGLegacyPass();
}
