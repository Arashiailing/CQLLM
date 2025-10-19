/**
 * @name 未知的初始化向量 (IV) 或 Nonce 使用
 * @description 识别在块密码操作中未明确配置初始化向量或nonce的实例。
 *              IV和nonce是密码学中的重要参数，用于确保相同明文在多次加密中产生不同密文。
 *              当这些参数来源不明或未正确配置时，可能使加密方案易受重放攻击和其他密码分析攻击。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查询所有块密码模式实例
from BlockMode cryptoBlockMode
// 检查实例是否缺少IV或nonce配置
where not cryptoBlockMode.hasIVorNonce()
// 输出结果
select cryptoBlockMode, "Block mode with unknown IV or Nonce configuration"