#ifndef LLVM_TRANSFORMS_INSTRUMENTATION_MYCFI_H
#define LLVM_TRANSFORMS_INSTRUMENTATION_MYCFI_H

#include "llvm/IR/PassManager.h"

namespace llvm {
class MyCFI: public PassInfoMixin<MyCFIPass> {
public:
  static bool isRequired() { return true; }
  PreservedAnalyses run(Module&, ModuleAnalysisManager&);
};
}


#endif  // LLVM_TRANSFORMS_INSTRUMENTATION_MYCFI_H
