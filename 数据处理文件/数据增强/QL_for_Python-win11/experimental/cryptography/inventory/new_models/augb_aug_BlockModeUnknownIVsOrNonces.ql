/**
 * @name 未配置初始化向量 (IV) 或 Nonce 的块密码模式
 * @description 检测在使用块密码模式时未配置初始化向量或nonce参数的情况。
 *              这些参数如果来源于不可信输入，可能引入安全漏洞。
 *              本查询关注量子计算准备和密码学物料清单(CBOM)相关风险。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 获取所有块密码模式实例
from BlockMode unconfiguredBlockMode
// 筛选条件：块模式未配置IV或nonce参数
where not unconfiguredBlockMode.hasIVorNonce()
// 输出结果：块模式实例及安全风险描述
select unconfiguredBlockMode, "Block mode with unknown IV or Nonce configuration"