; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=guard-widening -S < %s | FileCheck %s

declare i32 @llvm.experimental.deoptimize.i32(...)

; FIXME: Make sure the two loop-invariant conditions can be widened together,
;        and the widening point is outside the loop.
define i32 @test_01(i32 %start, i32 %x) {
; CHECK-LABEL: @test_01(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[COND:%.*]] = icmp eq i32 [[START:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[WC1:%.*]] = call i1 @llvm.experimental.widenable.condition()
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[START]], [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[WIDE_CHK:%.*]] = and i1 true, [[COND]]
; CHECK-NEXT:    [[TMP0:%.*]] = and i1 [[WIDE_CHK]], [[WC1]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[GUARD_BLOCK:%.*]], label [[EXIT_BY_WC:%.*]]
; CHECK:       exit_by_wc:
; CHECK-NEXT:    [[RVAL1:%.*]] = call i32 (...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 [[IV]]) ]
; CHECK-NEXT:    ret i32 [[RVAL1]]
; CHECK:       guard_block:
; CHECK-NEXT:    [[WC2:%.*]] = call i1 @llvm.experimental.widenable.condition()
; CHECK-NEXT:    [[GUARD:%.*]] = and i1 [[COND]], [[WC2]]
; CHECK-NEXT:    br i1 true, label [[BACKEDGE]], label [[FAILURE:%.*]]
; CHECK:       backedge:
; CHECK-NEXT:    call void @side_effect()
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 -1
; CHECK:       failure:
; CHECK-NEXT:    [[RVAL2:%.*]] = call i32 (...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 [[IV]]) ]
; CHECK-NEXT:    ret i32 [[RVAL2]]
;
entry:
  %cond = icmp eq i32 %start, %x
  %wc1 = call i1 @llvm.experimental.widenable.condition()
  br label %loop

loop:
  %iv = phi i32 [ %start, %entry ], [ %iv.next, %backedge ]
  br i1 %wc1, label %guard_block, label %exit_by_wc

exit_by_wc:
  %rval1 = call i32(...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 %iv) ]
  ret i32 %rval1

guard_block:
  %wc2 = call i1 @llvm.experimental.widenable.condition()
  %guard = and i1 %cond, %wc2
  br i1 %guard, label %backedge, label %failure

backedge:
  call void @side_effect()
  %iv.next = add i32 %iv, 1
  br label %loop

exit:
  ret i32 -1

failure:
  %rval2 = call i32(...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 %iv) ]
  ret i32 %rval2
}


; FIXME: Make sure the loop-variant condition is not widened into loop-invariant.
define i32 @test_02(i32 %start, i32 %x) {
; CHECK-LABEL: @test_02(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[WC1:%.*]] = call i1 @llvm.experimental.widenable.condition()
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[START:%.*]], [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[COND:%.*]] = icmp eq i32 [[IV]], [[X:%.*]]
; CHECK-NEXT:    [[WIDE_CHK:%.*]] = and i1 true, [[COND]]
; CHECK-NEXT:    [[TMP0:%.*]] = and i1 [[WIDE_CHK]], [[WC1]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[GUARD_BLOCK:%.*]], label [[EXIT_BY_WC:%.*]]
; CHECK:       exit_by_wc:
; CHECK-NEXT:    [[RVAL1:%.*]] = call i32 (...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 [[IV]]) ]
; CHECK-NEXT:    ret i32 [[RVAL1]]
; CHECK:       guard_block:
; CHECK-NEXT:    [[WC2:%.*]] = call i1 @llvm.experimental.widenable.condition()
; CHECK-NEXT:    [[GUARD:%.*]] = and i1 [[COND]], [[WC2]]
; CHECK-NEXT:    br i1 true, label [[BACKEDGE]], label [[FAILURE:%.*]]
; CHECK:       backedge:
; CHECK-NEXT:    call void @side_effect()
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 -1
; CHECK:       failure:
; CHECK-NEXT:    [[RVAL2:%.*]] = call i32 (...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 [[IV]]) ]
; CHECK-NEXT:    ret i32 [[RVAL2]]
;
entry:
  %wc1 = call i1 @llvm.experimental.widenable.condition()
  br label %loop

loop:
  %iv = phi i32 [ %start, %entry ], [ %iv.next, %backedge ]
  br i1 %wc1, label %guard_block, label %exit_by_wc

exit_by_wc:
  %rval1 = call i32(...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 %iv) ]
  ret i32 %rval1

guard_block:
  %cond = icmp eq i32 %iv, %x
  %wc2 = call i1 @llvm.experimental.widenable.condition()
  %guard = and i1 %cond, %wc2
  br i1 %guard, label %backedge, label %failure

backedge:
  call void @side_effect()
  %iv.next = add i32 %iv, 1
  br label %loop

exit:
  ret i32 -1

failure:
  %rval2 = call i32(...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 %iv) ]
  ret i32 %rval2
}

; FIXME: Same as test_01, but the initial condition is not immediately WC.
define i32 @test_03(i32 %start, i32 %x, i1 %c) {
; CHECK-LABEL: @test_03(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[COND:%.*]] = icmp eq i32 [[START:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[WC1:%.*]] = call i1 @llvm.experimental.widenable.condition()
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[START]], [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[WIDE_CHK:%.*]] = and i1 [[C:%.*]], [[COND]]
; CHECK-NEXT:    [[INVARIANT:%.*]] = and i1 [[WIDE_CHK]], [[WC1]]
; CHECK-NEXT:    br i1 [[INVARIANT]], label [[GUARD_BLOCK:%.*]], label [[EXIT_BY_WC:%.*]]
; CHECK:       exit_by_wc:
; CHECK-NEXT:    [[RVAL1:%.*]] = call i32 (...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 [[IV]]) ]
; CHECK-NEXT:    ret i32 [[RVAL1]]
; CHECK:       guard_block:
; CHECK-NEXT:    [[WC2:%.*]] = call i1 @llvm.experimental.widenable.condition()
; CHECK-NEXT:    [[GUARD:%.*]] = and i1 [[COND]], [[WC2]]
; CHECK-NEXT:    br i1 true, label [[BACKEDGE]], label [[FAILURE:%.*]]
; CHECK:       backedge:
; CHECK-NEXT:    call void @side_effect()
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    br label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 -1
; CHECK:       failure:
; CHECK-NEXT:    [[RVAL2:%.*]] = call i32 (...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 [[IV]]) ]
; CHECK-NEXT:    ret i32 [[RVAL2]]
; CHECK:       early_failure:
; CHECK-NEXT:    [[RVAL3:%.*]] = call i32 (...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 [[X]]) ]
; CHECK-NEXT:    ret i32 [[RVAL3]]
;
entry:
  %cond = icmp eq i32 %start, %x
  %wc1 = call i1 @llvm.experimental.widenable.condition()
  %invariant = and i1 %c, %wc1
  br label %loop

loop:
  %iv = phi i32 [ %start, %entry ], [ %iv.next, %backedge ]
  br i1 %invariant, label %guard_block, label %exit_by_wc

exit_by_wc:
  %rval1 = call i32(...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 %iv) ]
  ret i32 %rval1

guard_block:
  %wc2 = call i1 @llvm.experimental.widenable.condition()
  %guard = and i1 %cond, %wc2
  br i1 %guard, label %backedge, label %failure

backedge:
  call void @side_effect()
  %iv.next = add i32 %iv, 1
  br label %loop

exit:
  ret i32 -1

failure:
  %rval2 = call i32(...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 %iv) ]
  ret i32 %rval2

early_failure:
  %rval3 = call i32(...) @llvm.experimental.deoptimize.i32() [ "deopt"(i32 %x) ]
  ret i32 %rval3
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(inaccessiblemem: readwrite)
declare i1 @llvm.experimental.widenable.condition()

declare void @side_effect()
