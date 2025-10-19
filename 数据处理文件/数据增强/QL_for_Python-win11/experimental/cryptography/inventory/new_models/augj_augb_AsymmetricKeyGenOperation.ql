/**
 * @name 非对称密钥生成源检测
 * @description 在加密库中识别所有可能的非对称密钥生成操作及其配置来源。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 识别非对称密钥生成操作及其配置来源
from AsymmetricKeyGen asymmetricKeyOperation, DataFlow::Node keyConfigurationSource
where asymmetricKeyOperation.getKeyConfigSrc() = keyConfigurationSource
select asymmetricKeyOperation,
  "检测到使用算法 " + asymmetricKeyOperation.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置源 $@", keyConfigurationSource, keyConfigurationSource.toString()