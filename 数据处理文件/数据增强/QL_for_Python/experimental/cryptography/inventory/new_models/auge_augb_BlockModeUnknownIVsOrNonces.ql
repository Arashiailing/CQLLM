/**
 * @name 未经验证的初始化向量 (IV) 或 nonce 使用
 * @description 检测加密操作中使用了来源不明的初始化向量 (IV) 或 nonce。
 *              这些参数对于确保加密强度至关重要，来源不明可能导致加密漏洞。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 获取所有块密码操作实例
from BlockMode cryptoOperation
// 检查块密码操作是否缺少 IV 或 nonce 配置
where not cryptoOperation.hasIVorNonce()
// 报告未正确配置 IV 或 nonce 的块密码操作
select cryptoOperation, "Block cipher operation without proper IV or Nonce configuration"