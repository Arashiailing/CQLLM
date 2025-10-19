/**
 * @name 未知初始化向量 (IV) 或 nonce
 * @description 检测块密码模式中未配置初始化向量或nonce的情况，这些参数可能来源于不可信的输入
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 检索所有块密码模式实例
from BlockMode blockCipherModeInstance
// 筛选未配置IV或nonce参数的实例
where not blockCipherModeInstance.hasIVorNonce()
// 输出存在安全风险的块模式实例及描述
select blockCipherModeInstance, "Block mode with unknown IV or Nonce configuration"