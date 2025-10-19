/**
 * @name 非对称密钥生成源检测
 * @description 识别在使用支持加密库的代码中，所有已知的潜在非对称密钥生成源。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作及其配置源
from AsymmetricKeyGen keyGenOp, DataFlow::Node keyConfigSource
where keyGenOp.getKeyConfigSrc() = keyConfigSource
select keyGenOp,
  "检测到使用算法 " + keyGenOp.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置源 $@", keyConfigSource, keyConfigSource.toString()