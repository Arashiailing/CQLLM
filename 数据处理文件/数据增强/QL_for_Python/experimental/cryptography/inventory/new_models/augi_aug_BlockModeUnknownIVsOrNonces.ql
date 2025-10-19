/**
 * @name 未配置初始化向量 (IV) 或 nonce 的块密码模式
 * @description 此查询识别在加密操作中使用块密码模式时，未正确配置初始化向量(IV)或nonce的情况。
 *              IV/nonce是块密码安全性的关键参数，若未配置或来源于不可信输入，可能导致加密弱点。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 从所有块密码模式实例中筛选
from BlockMode cryptoBlockMode
// 检查块模式是否缺少IV或nonce配置
where not cryptoBlockMode.hasIVorNonce()
// 输出结果：报告未配置IV/nonce的块模式实例及安全风险描述
select cryptoBlockMode, "Block mode with unknown IV or Nonce configuration"