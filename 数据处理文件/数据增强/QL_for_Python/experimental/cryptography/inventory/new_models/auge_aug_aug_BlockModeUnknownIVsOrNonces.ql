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

// 查找所有块密码模式实例，并筛选出未正确配置IV或nonce的实例
// 这些实例可能存在安全风险，因为IV/nonce可能来源于不可信的输入源
from BlockMode insecureBlockMode
where not insecureBlockMode.hasIVorNonce()
// 输出检测到的存在安全风险的块模式实例及相关描述信息
select insecureBlockMode, "Block mode with unknown IV or Nonce configuration"