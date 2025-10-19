/**
 * @name 未配置的初始化向量 (IV) 或 nonce
 * @description 识别块密码加密操作中未正确配置初始化向量或nonce的实例。
 *              这些参数对于确保加密安全性至关重要，当缺失或来源不可信时，
 *              可能导致加密方案易受攻击。此查询旨在检测所有未配置IV或nonce的
 *              块密码加密模式，帮助预防潜在的密码分析攻击。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 识别所有块密码加密模式
from BlockMode encryptionMode
// 检查是否存在未配置IV或nonce的情况
// IV和nonce是确保加密安全性的关键参数，
// 它们能够防止相同明文产生相同密文，从而避免模式识别攻击
// 当这些参数缺失时，加密数据的安全性将受到严重威胁
where not encryptionMode.hasIVorNonce()
// 输出检测结果和安全风险提示
select encryptionMode, "Block mode with unknown IV or Nonce configuration"