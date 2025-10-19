/**
 * @name 未配置初始化向量 (IV) 或 Nonce 的块密码模式
 * @description 此查询识别在使用块密码操作模式时，未正确配置初始化向量(IV)或Nonce参数的安全隐患。
 *              在现代密码学实践中，IV或Nonce对于确保加密模式的安全性至关重要。这些参数若未配置或来源于不可信输入，
 *              可能导致加密算法的可预测性和脆弱性，特别是在量子计算环境下，这种风险更加显著。
 *              本查询作为密码学物料清单(CBOM)分析的一部分，关注量子计算准备相关的密码学实现问题。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义查询目标：识别存在安全隐患的块密码模式实例
from BlockMode insecureBlockModeInstance

// 应用安全筛选条件：检查块模式是否缺少必要的IV或Nonce配置
where not insecureBlockModeInstance.hasIVorNonce()

// 生成查询结果：报告不符合安全标准的块模式实现
select insecureBlockModeInstance, "Block mode with unknown IV or Nonce configuration"