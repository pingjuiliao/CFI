
#include "llvm/Transforms/Instrumentation/MyCFI.h"

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

PreservedAnalyses MyCFIPass::run(Module &M, ModuleAnalysisManager &AM) {
  if (M.getModuleFlag("kcfi")) {
    return PreservedAnalyses::all();
  }
  for (auto &F: M) {
    errs() << F.getName() << "\n";
  }
  return PreservedAnalyses::none();
}
