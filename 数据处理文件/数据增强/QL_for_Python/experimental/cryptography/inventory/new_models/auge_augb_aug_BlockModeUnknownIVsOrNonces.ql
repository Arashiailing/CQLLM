/**
 * @name 块密码模式中缺失初始化向量(IV)或Nonce配置
 * @description 识别块密码操作中未正确配置初始化向量或Nonce参数的实例。
 *              当这些关键参数未设置或来源不明时，可能导致加密强度降低，
 *              特别是在量子计算威胁背景下。此查询支持密码学物料清单(CBOM)分析。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义查询目标：检测所有块密码模式实例
from BlockMode insecureBlockMode
// 应用过滤条件：识别未配置IV或Nonce的块模式
where not insecureBlockMode.hasIVorNonce()
// 生成结果：报告不安全的块模式实例及相关风险信息
select insecureBlockMode, "Block mode with unknown IV or Nonce configuration"