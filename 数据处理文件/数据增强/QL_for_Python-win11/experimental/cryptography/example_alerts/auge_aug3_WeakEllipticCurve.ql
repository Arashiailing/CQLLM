/**
 * @name Weak elliptic curve
 * @description Identifies the usage of cryptographic algorithms that are either unapproved or considered weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// 定义一组被认可的椭圆曲线算法
string approvedEllipticCurves() {
  result =
    [
      "SECP256R1", "PRIME256V1",  // P-256 curves
      "SECP384R1",               // P-384 curve
      "SECP521R1",               // P-521 curve
      "ED25519",                 // Ed25519 curve
      "X25519"                   // X25519 curve
    ]
}

// 从椭圆曲线算法实例中提取信息并检测不安全的曲线
from EllipticCurveAlgorithm curveAlgorithm, string warningMessage, string ellipticCurveName
where
  // 提取当前使用的椭圆曲线名称
  ellipticCurveName = curveAlgorithm.getCurveName() and
  (
    // 检测未识别的曲线算法
    ellipticCurveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // 检测弱曲线算法（不在被认可的列表中）
    ellipticCurveName != unknownAlgorithm() and
    not ellipticCurveName = approvedEllipticCurves() and
    warningMessage = "Use of weak curve algorithm " + ellipticCurveName + "."
  )
select curveAlgorithm, warningMessage