/**
 * @name Weak elliptic curve
 * @description Identifies the usage of cryptographic algorithms that are either unapproved
 *              or considered weak in terms of security. This query specifically targets
 *              elliptic curve algorithms that do not meet recommended security standards.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python  // 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  // 导入实验性的加密概念库

// 从椭圆曲线算法操作符中选择数据，并定义警报消息和曲线名称
from EllipticCurveAlgorithm curveOperation, string alertMessage, string curveName
where
  // 获取曲线名称
  curveName = curveOperation.getCurveName() and
  (
    // 情况1：曲线名称为未知算法
    curveName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // 情况2：曲线名称不在安全曲线列表中
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256曲线
        "SECP384R1",              // P-384曲线
        "SECP521R1",              // P-521曲线
        "ED25519",                // Ed25519曲线
        "X25519"                  // X25519曲线
      ] and
    alertMessage = "Use of weak curve algorithm " + curveName + "."
  )
select curveOperation, alertMessage  // 选择操作符和警报消息进行输出