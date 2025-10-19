/**
 * @name Weak elliptic curve
 * @description Finds uses of cryptography algorithms that are unapproved or otherwise weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// 定义安全曲线算法列表
string getSecureCurve() {
  result =
    [
      "SECP256R1", "PRIME256V1",  // P-256 curves
      "SECP384R1",               // P-384 curve
      "SECP521R1",               // P-521 curve
      "ED25519",                 // Ed25519 curve
      "X25519"                   // X25519 curve
    ]
}

// 从椭圆曲线算法实例中提取信息并检测弱曲线
from EllipticCurveAlgorithm algo, string alertMsg, string curveName
where
  // 获取当前使用的曲线名称
  curveName = algo.getCurveName() and
  (
    // 情况1：检测未识别的曲线算法
    curveName = unknownAlgorithm() and
    alertMsg = "Use of unrecognized curve algorithm."
    or
    // 情况2：检测弱曲线算法
    curveName != unknownAlgorithm() and
    not curveName = getSecureCurve() and
    alertMsg = "Use of weak curve algorithm " + curveName + "."
  )
select algo, alertMsg