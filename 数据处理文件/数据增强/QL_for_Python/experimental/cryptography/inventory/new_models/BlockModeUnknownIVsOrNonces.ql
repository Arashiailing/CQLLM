/**
 * @name 未知初始化向量 (IV) 或 nonce
 * @description 查找所有可能的未知来源的初始化向量 (IV) 或 nonce，这些向量用于在使用受支持库时的块密码中。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 从 BlockMode 类中选择算法 (alg)
from BlockMode alg
// 条件：算法没有 IV 或 nonce
where not alg.hasIVorNonce()
// 选择结果：算法和描述信息
select alg, "Block mode with unknown IV or Nonce configuration"
