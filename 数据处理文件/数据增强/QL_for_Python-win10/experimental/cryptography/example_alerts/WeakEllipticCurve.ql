/**
 * @name Weak elliptic curve
 * @description Finds uses of cryptography algorithms that are unapproved or otherwise weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python  // 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  // 导入实验性的加密概念库

// 从EllipticCurveAlgorithm操作符中选择数据，并定义消息和名称字符串
from EllipticCurveAlgorithm op, string msg, string name
where
  (
    // 获取曲线名称并与名称匹配，且名称为未知算法时，设置消息为“使用未识别的曲线算法”
    name = op.getCurveName() and
    name = unknownAlgorithm() and
    msg = "Use of unrecognized curve algorithm."
    or
    // 如果名称不是未知算法，则检查名称是否在预定义的安全曲线列表中
    name != unknownAlgorithm() and
    name = op.getCurveName() and
    // 如果名称不在安全曲线列表中，则设置消息为“使用弱曲线算法”并附加曲线名称
    not name =
      [
        "SECP256R1", "PRIME256V1", // P-256曲线
        "SECP384R1",              // P-384曲线
        "SECP521R1",              // P-521曲线
        "ED25519",                // Ed25519曲线
        "X25519"                  // X25519曲线
      ] and
    msg = "Use of weak curve algorithm " + name + "."
  )
select op, msg  // 选择操作符和消息进行输出
