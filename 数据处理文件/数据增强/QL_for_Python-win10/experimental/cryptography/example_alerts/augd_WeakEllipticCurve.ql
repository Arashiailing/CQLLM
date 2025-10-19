/**
 * @name Weak elliptic curve
 * @description Identifies the use of cryptography algorithms that are either unapproved or considered weak.
 *              This query specifically focuses on elliptic curve algorithms used in Python code.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python  // 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  // 导入实验性的加密概念库

// 从椭圆曲线算法操作符中选择数据，并定义警告消息和曲线名称
from EllipticCurveAlgorithm ellipticCurveOp, string warningMessage, string curveName
where
  (
    // 情况1：曲线名称为未知算法
    curveName = ellipticCurveOp.getCurveName() and
    curveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
  )
  or
  (
    // 情况2：曲线名称已知但不安全
    curveName = ellipticCurveOp.getCurveName() and
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256曲线
        "SECP384R1",              // P-384曲线
        "SECP521R1",              // P-521曲线
        "ED25519",                // Ed25519曲线
        "X25519"                  // X25519曲线
      ] and
    warningMessage = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveOp, warningMessage  // 输出椭圆曲线操作符和相应的警告消息