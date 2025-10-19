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

// 查询所有块密码模式实例
from BlockMode blockMode
// 筛选条件：块模式未配置IV或nonce参数
where not blockMode.hasIVorNonce()
// 输出结果：块模式实例及安全风险描述
select blockMode, "Block mode with unknown IV or Nonce configuration"