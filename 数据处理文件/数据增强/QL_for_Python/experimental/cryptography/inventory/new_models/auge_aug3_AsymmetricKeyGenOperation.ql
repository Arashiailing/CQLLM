/**
 * @name 非对称密钥生成源识别
 * @description 检测代码中使用受支持库生成的所有非对称密钥，并追踪其配置来源。
 *              此查询分析非对称密钥生成操作及其配置数据流，帮助识别潜在的
 *              密钥管理问题和安全风险。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 识别非对称密钥生成操作及其配置来源
// 通过分析密钥生成操作的配置数据流，追踪密钥生成模式
from AsymmetricKeyGen asymmetricKeyGenOperation, DataFlow::Node keyConfigurationSource
where 
  // 确保配置源与密钥生成操作关联
  asymmetricKeyGenOperation.getKeyConfigSrc() = keyConfigurationSource
select 
  asymmetricKeyGenOperation,
  "检测到非对称密钥生成，使用算法: " + asymmetricKeyGenOperation.getAlgorithm().getName() +
    "，密钥配置源: $@", keyConfigurationSource, keyConfigurationSource.toString()