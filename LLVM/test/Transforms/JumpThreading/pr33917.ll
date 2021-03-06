; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -jump-threading -correlated-propagation %s -S | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare i8* @foo()

declare i32 @rust_eh_personality() unnamed_addr

; Function Attrs: nounwind
declare void @llvm.assume(i1) #0

define void @patatino() personality i32 ()* @rust_eh_personality {
; CHECK-LABEL: @patatino(
; CHECK-NEXT:  bb9:
; CHECK-NEXT:    [[T9:%.*]] = invoke i8* @foo()
; CHECK-NEXT:    to label [[GOOD:%.*]] unwind label [[BAD:%.*]]
; CHECK:       bad:
; CHECK-NEXT:    [[T10:%.*]] = landingpad { i8*, i32 }
; CHECK-NEXT:    cleanup
; CHECK-NEXT:    resume { i8*, i32 } [[T10]]
; CHECK:       good:
; CHECK-NEXT:    [[T11:%.*]] = icmp ne i8* [[T9]], null
; CHECK-NEXT:    [[T12:%.*]] = zext i1 [[T11]] to i64
; CHECK-NEXT:    [[COND:%.*]] = icmp eq i64 [[T12]], 1
; CHECK-NEXT:    br i1 [[COND]], label [[IF_TRUE:%.*]], label [[DONE:%.*]]
; CHECK:       if_true:
; CHECK-NEXT:    call void @llvm.assume(i1 [[T11]])
; CHECK-NEXT:    br label [[DONE]]
; CHECK:       done:
; CHECK-NEXT:    ret void
;
bb9:
  %t9 = invoke i8* @foo()
  to label %good unwind label %bad

bad:
  %t10 = landingpad { i8*, i32 }
  cleanup
  resume { i8*, i32 } %t10

good:
  %t11 = icmp ne i8* %t9, null
  %t12 = zext i1 %t11 to i64
  %cond = icmp eq i64 %t12, 1
  br i1 %cond, label %if_true, label %done

if_true:
  call void @llvm.assume(i1 %t11)
  br label %done

done:
  ret void
}

attributes #0 = { nounwind }
