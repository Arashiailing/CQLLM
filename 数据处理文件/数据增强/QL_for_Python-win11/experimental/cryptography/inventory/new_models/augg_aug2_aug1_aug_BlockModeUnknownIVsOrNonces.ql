/**
 * @name 未配置的初始化向量 (IV) 或 nonce
 * @description 检测使用块密码加密时未正确设置初始化向量或nonce的情况。
 *              当这些关键参数来源不可信时，可能导致严重的安全漏洞。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查询所有块密码加密模式实例
from BlockMode insecureEncryptionMode
// 安全检查：验证加密操作是否配置了必要的IV或nonce参数
// 缺少这些参数会导致加密过程不安全，易受攻击
where not insecureEncryptionMode.hasIVorNonce()
// 输出检测结果：标识存在安全风险的加密模式实例
select insecureEncryptionMode, "Block mode with unknown IV or Nonce configuration"