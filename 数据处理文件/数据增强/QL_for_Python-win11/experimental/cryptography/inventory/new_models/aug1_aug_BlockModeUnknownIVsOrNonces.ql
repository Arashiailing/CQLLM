/**
 * @name 未配置的初始化向量 (IV) 或 nonce
 * @description 识别使用块密码模式时未正确配置初始化向量或nonce的加密操作，
 *              这些参数如果来自不可信输入可能导致安全漏洞
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查找所有块密码模式实例
from BlockMode cipherMode
// 筛选出未配置IV或nonce的加密模式
where not cipherMode.hasIVorNonce()
// 输出问题实例及安全风险描述
select cipherMode, "Block mode with unknown IV or Nonce configuration"