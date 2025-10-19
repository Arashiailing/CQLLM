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

// 查询目标：定位所有使用块密码模式的代码实例
// 这些实例可能存在安全风险，特别是当IV或nonce未正确配置时
from BlockMode insecureCipherMode
where 
    // 筛选条件：检查块密码模式是否未配置IV或nonce
    // 未配置这些参数可能导致加密操作不安全，易受攻击
    not insecureCipherMode.hasIVorNonce()
select 
    // 输出结果：报告存在安全风险的块模式实例
    insecureCipherMode, 
    // 提供问题描述
    "Block mode with unknown IV or Nonce configuration"