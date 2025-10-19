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

// 本查询专注于识别非对称密钥生成操作并追踪其配置来源
// 通过分析密钥生成过程中的配置数据流，揭示密钥管理模式
// 有助于发现潜在的安全配置问题和密钥管理风险
from AsymmetricKeyGen keyGenOp, DataFlow::Node configSource
where 
  // 确保密钥生成操作与其配置源之间建立正确的数据流关系
  // 此条件是追踪密钥配置来源的核心逻辑
  keyGenOp.getKeyConfigSrc() = configSource
select 
  keyGenOp,
  // 构建包含算法信息和配置源位置的详细结果消息
  "检测到非对称密钥生成，使用算法: " + keyGenOp.getAlgorithm().getName() +
    "，密钥配置源: $@", configSource, configSource.toString()