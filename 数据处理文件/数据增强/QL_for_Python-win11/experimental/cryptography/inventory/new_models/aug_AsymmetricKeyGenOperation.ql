/**
 * @name 已知非对称密钥源生成
 * @description 识别代码库中所有通过受支持的加密库生成的非对称密钥。
 *              此查询追踪密钥生成操作及其配置源，有助于评估系统对量子计算威胁的抵御能力。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作及其关联的配置源
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigSource
where asymmetricKeyGeneration.getKeyConfigSrc() = keyConfigSource
// 提取算法名称以提高可读性
select asymmetricKeyGeneration,
  "使用算法 " + asymmetricKeyGeneration.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置源 $@", keyConfigSource, keyConfigSource.toString()