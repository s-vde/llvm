; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define <4 x float> @test_vfmadd_ss(<4 x float> %a, <4 x float> %b, <4 x float> %c) {
; CHECK-LABEL: @test_vfmadd_ss(
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <4 x float> [[A:%.*]], i64 0
; CHECK-NEXT:    [[TMP2:%.*]] = extractelement <4 x float> [[B:%.*]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <4 x float> [[C:%.*]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = call float @llvm.fma.f32(float [[TMP1]], float [[TMP2]], float [[TMP3]])
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <4 x float> [[A]], float [[TMP4]], i64 0
; CHECK-NEXT:    ret <4 x float> [[TMP5]]
;
  %1 = insertelement <4 x float> %b, float 1.000000e+00, i32 1
  %2 = insertelement <4 x float> %1, float 2.000000e+00, i32 2
  %3 = insertelement <4 x float> %2, float 3.000000e+00, i32 3
  %4 = insertelement <4 x float> %c, float 4.000000e+00, i32 1
  %5 = insertelement <4 x float> %4, float 5.000000e+00, i32 2
  %6 = insertelement <4 x float> %5, float 6.000000e+00, i32 3
  %7 = extractelement <4 x float> %a, i64 0
  %8 = extractelement <4 x float> %3, i64 0
  %9 = extractelement <4 x float> %6, i64 0
  %10 = call float @llvm.fma.f32(float %7, float %8, float %9)
  %11 = insertelement <4 x float> %a, float %10, i64 0
  ret <4 x float> %11
}

define float @test_vfmadd_ss_0(<4 x float> %a, <4 x float> %b, <4 x float> %c) {
; CHECK-LABEL: @test_vfmadd_ss_0(
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <4 x float> [[A:%.*]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = extractelement <4 x float> [[B:%.*]], i64 0
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <4 x float> [[C:%.*]], i64 0
; CHECK-NEXT:    [[TMP4:%.*]] = call float @llvm.fma.f32(float [[TMP1]], float [[TMP2]], float [[TMP3]])
; CHECK-NEXT:    ret float [[TMP4]]
;
  %1 = insertelement <4 x float> %a, float 1.000000e+00, i32 1
  %2 = insertelement <4 x float> %1, float 2.000000e+00, i32 2
  %3 = insertelement <4 x float> %2, float 3.000000e+00, i32 3
  %4 = extractelement <4 x float> %3, i64 0
  %5 = extractelement <4 x float> %b, i64 0
  %6 = extractelement <4 x float> %c, i64 0
  %7 = call float @llvm.fma.f32(float %4, float %5, float %6)
  %8 = insertelement <4 x float> %3, float %7, i64 0
  %9 = extractelement <4 x float> %8, i32 0
  ret float %9
}

define float @test_vfmadd_ss_1(<4 x float> %a, <4 x float> %b, <4 x float> %c) {
; CHECK-LABEL: @test_vfmadd_ss_1(
; CHECK-NEXT:    ret float 1.000000e+00
;
  %1 = insertelement <4 x float> %a, float 1.000000e+00, i32 1
  %2 = insertelement <4 x float> %1, float 2.000000e+00, i32 2
  %3 = insertelement <4 x float> %2, float 3.000000e+00, i32 3
  %4 = extractelement <4 x float> %3, i64 0
  %5 = extractelement <4 x float> %b, i64 0
  %6 = extractelement <4 x float> %c, i64 0
  %7 = call float @llvm.fma.f32(float %4, float %5, float %6)
  %8 = insertelement <4 x float> %3, float %7, i64 0
  %9 = extractelement <4 x float> %8, i32 1
  ret float %9
}

define <2 x double> @test_vfmadd_sd(<2 x double> %a, <2 x double> %b, <2 x double> %c) {
; CHECK-LABEL: @test_vfmadd_sd(
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <2 x double> [[A:%.*]], i64 0
; CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x double> [[B:%.*]], i64 0
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <2 x double> [[C:%.*]], i64 0
; CHECK-NEXT:    [[TMP4:%.*]] = call double @llvm.fma.f64(double [[TMP1]], double [[TMP2]], double [[TMP3]])
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x double> [[A]], double [[TMP4]], i64 0
; CHECK-NEXT:    ret <2 x double> [[TMP5]]
;
  %1 = insertelement <2 x double> %b, double 1.000000e+00, i32 1
  %2 = insertelement <2 x double> %c, double 2.000000e+00, i32 1
  %3 = extractelement <2 x double> %a, i64 0
  %4 = extractelement <2 x double> %1, i64 0
  %5 = extractelement <2 x double> %2, i64 0
  %6 = call double @llvm.fma.f64(double %3, double %4, double %5)
  %7 = insertelement <2 x double> %a, double %6, i64 0
  ret <2 x double> %7
}

define double @test_vfmadd_sd_0(<2 x double> %a, <2 x double> %b, <2 x double> %c) {
; CHECK-LABEL: @test_vfmadd_sd_0(
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <2 x double> [[A:%.*]], i64 0
; CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x double> [[B:%.*]], i64 0
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <2 x double> [[C:%.*]], i64 0
; CHECK-NEXT:    [[TMP4:%.*]] = call double @llvm.fma.f64(double [[TMP1]], double [[TMP2]], double [[TMP3]])
; CHECK-NEXT:    ret double [[TMP4]]
;
  %1 = insertelement <2 x double> %a, double 1.000000e+00, i32 1
  %2 = extractelement <2 x double> %1, i64 0
  %3 = extractelement <2 x double> %b, i64 0
  %4 = extractelement <2 x double> %c, i64 0
  %5 = call double @llvm.fma.f64(double %2, double %3, double %4)
  %6 = insertelement <2 x double> %1, double %5, i64 0
  %7 = extractelement <2 x double> %6, i32 0
  ret double %7
}

define double @test_vfmadd_sd_1(<2 x double> %a, <2 x double> %b, <2 x double> %c) {
; CHECK-LABEL: @test_vfmadd_sd_1(
; CHECK-NEXT:    ret double 1.000000e+00
;
  %1 = insertelement <2 x double> %a, double 1.000000e+00, i32 1
  %2 = extractelement <2 x double> %1, i64 0
  %3 = extractelement <2 x double> %b, i64 0
  %4 = extractelement <2 x double> %c, i64 0
  %5 = call double @llvm.fma.f64(double %2, double %3, double %4)
  %6 = insertelement <2 x double> %1, double %5, i64 0
  %7 = extractelement <2 x double> %6, i32 1
  ret double %7
}

declare float @llvm.fma.f32(float, float, float)
declare double @llvm.fma.f64(double, double, double)
