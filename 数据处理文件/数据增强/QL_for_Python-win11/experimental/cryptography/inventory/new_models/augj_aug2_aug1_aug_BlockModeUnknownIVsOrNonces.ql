/**
 * @name 未配置的初始化向量 (IV) 或 nonce
 * @description 识别块密码加密操作中初始化向量或nonce未正确配置的安全隐患。
 *              当这些关键加密参数来源不可信或未设置时，会破坏加密方案的安全性，
 *              可能导致密文可预测、重放攻击等严重安全风险。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义查询范围：所有块密码加密模式实例
from BlockMode insecureBlockMode
// 应用安全过滤条件：检测未配置IV或nonce的加密操作
where not insecureBlockMode.hasIVorNonce()
// 输出检测结果：定位存在安全风险的加密模式实例
select insecureBlockMode, "Block mode with unknown IV or Nonce configuration"