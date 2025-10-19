/**
 * @name 未知的初始化向量 (IV) 或 nonce 配置
 * @description 识别在块密码操作中未正确配置初始化向量或nonce的情况，
 *              这些关键参数可能来源于不可信的输入源，导致安全风险
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 直接查询并筛选未配置IV或nonce的块密码模式实例
from BlockMode improperlyConfiguredBlockMode
where not improperlyConfiguredBlockMode.hasIVorNonce()
// 输出检测结果：识别出的配置不当的块模式实例及其安全风险描述
select improperlyConfiguredBlockMode, "Block mode with unknown IV or Nonce configuration"