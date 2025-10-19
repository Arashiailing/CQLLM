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

// 获取所有块密码加密模式的实例
from BlockMode blockCipherMode
// 筛选条件：识别没有配置IV或nonce的加密操作
where not blockCipherMode.hasIVorNonce()
// 返回检测结果及安全风险提示
select blockCipherMode, "Block mode with unknown IV or Nonce configuration"