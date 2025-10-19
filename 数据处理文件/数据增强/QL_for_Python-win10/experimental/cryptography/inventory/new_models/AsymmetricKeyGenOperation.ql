/**
 * @name 已知非对称密钥源生成
 * @description 在使用受支持的库时，查找所有已知的潜在非对称密钥生成源。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 从 AsymmetricKeyGen 操作和数据流节点 confSrc 中导入
from AsymmetricKeyGen op, DataFlow::Node confSrc
// 条件：op 获取密钥配置源等于 confSrc
where op.getKeyConfigSrc() = confSrc
// 选择操作 op、算法名称和配置源信息
select op,
  "使用算法 " + op.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置源 $@", confSrc, confSrc.toString()
