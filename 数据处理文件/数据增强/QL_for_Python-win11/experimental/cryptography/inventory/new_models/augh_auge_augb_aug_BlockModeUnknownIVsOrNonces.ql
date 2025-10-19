/**
 * @name 块密码模式中缺失初始化向量(IV)或Nonce配置
 * @description 此查询检测块密码操作中未正确配置初始化向量或Nonce参数的实例。
 *              在量子计算威胁背景下，这些关键参数的缺失或来源不明会显著降低加密强度。
 *              本查询支持密码学物料清单(CBOM)分析，帮助识别潜在的加密弱点。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查询目标：识别所有块密码模式实例
from BlockMode vulnerableBlockMode

// 过滤条件：筛选出未配置IV或Nonce的块模式，这些模式存在安全风险
where not vulnerableBlockMode.hasIVorNonce()

// 结果输出：报告不安全的块模式实例及其风险描述
select vulnerableBlockMode, "Block mode with unknown IV or Nonce configuration"