/**
 * @name 未配置初始化向量 (IV) 或 nonce
 * @description 检测块密码算法中未正确配置初始化向量 (IV) 或 nonce 的情况。
 *              IV/nonce 是确保加密安全性的关键参数，缺失或来源不明可能导致加密方案被破解。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查找所有块密码模式实例
from BlockMode blockModeInstance
// 检查块密码模式是否缺少 IV 或 nonce 配置
where not blockModeInstance.hasIVorNonce()
// 输出问题结果
select blockModeInstance, "Block mode with unknown IV or Nonce configuration"