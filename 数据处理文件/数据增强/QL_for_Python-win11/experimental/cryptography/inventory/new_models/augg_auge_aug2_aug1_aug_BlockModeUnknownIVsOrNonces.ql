/**
 * @name 未配置的初始化向量 (IV) 或 nonce
 * @description 检测使用块密码加密时未正确设置初始化向量或nonce的情况。
 *              当这些关键参数来源不可信时，可能导致严重的安全漏洞。
 *              此查询识别所有未配置IV或nonce的块密码加密模式实例，
 *              这些实例可能容易受到密码分析攻击。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查找所有块密码加密模式实例
from BlockMode blockCipherMode
// 筛选条件：检测未配置IV或nonce的加密操作
// 初始化向量(IV)或nonce是块密码加密中的关键参数，
// 它们确保相同明文加密产生不同密文，防止模式识别攻击
// 缺少这些参数可能导致加密数据容易被破解
where not blockCipherMode.hasIVorNonce()
// 输出检测结果和安全风险提示
select blockCipherMode, "Block mode with unknown IV or Nonce configuration"