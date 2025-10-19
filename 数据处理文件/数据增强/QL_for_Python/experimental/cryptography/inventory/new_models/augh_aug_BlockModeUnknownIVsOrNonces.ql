/**
 * @name 未知初始化向量 (IV) 或 nonce
 * @description 检测块密码模式中未配置初始化向量或nonce的情况，这些参数可能来源于不可信的输入。
 *              在加密算法中，IV(初始化向量)和nonce(仅使用一次的数字)是确保相同明文加密后产生不同密文的关键参数。
 *              当这些参数未正确配置或来源不明时，可能导致加密方案容易被攻击者破解。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义查询范围：所有块密码模式实例
from BlockMode cipherBlockMode
// 筛选条件：检查块密码模式是否缺少IV或nonce配置
// 这表示加密操作可能使用了默认值或随机生成的参数，而非安全配置的参数
where not cipherBlockMode.hasIVorNonce()
// 输出结果：标识存在安全风险的块密码模式实例及问题描述
select cipherBlockMode, "Block mode with unknown IV or Nonce configuration"