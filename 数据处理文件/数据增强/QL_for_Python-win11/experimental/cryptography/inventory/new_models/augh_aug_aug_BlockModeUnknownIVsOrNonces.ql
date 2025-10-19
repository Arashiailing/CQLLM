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

// 定位所有块密码模式实例中缺少IV或nonce配置的情况
from BlockMode insecureBlockMode
// 筛选条件：块密码模式实例没有正确配置初始化向量或nonce
where not insecureBlockMode.hasIVorNonce()
// 报告结果：标识存在安全风险的块密码模式实例
select insecureBlockMode, "Block mode with unknown IV or Nonce configuration"