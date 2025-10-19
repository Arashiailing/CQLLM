/**
 * @name 非对称密钥生成源识别
 * @description 识别代码中通过受支持库生成的非对称密钥，并追踪其配置来源。
 *              本查询分析非对称密钥生成操作及其配置数据流，以帮助发现潜在的
 *              密钥管理问题与安全风险。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作及其关联的配置源
// 通过匹配密钥生成操作的配置源与数据流节点，识别密钥生成模式
from AsymmetricKeyGen asymmetricKeyGen, DataFlow::Node configSourceNode
where 
  asymmetricKeyGen.getKeyConfigSrc() = configSourceNode
select asymmetricKeyGen,
  "检测到非对称密钥生成，使用算法: " + 
  asymmetricKeyGen.getAlgorithm().getName() + 
  "，密钥配置源: $@", 
  configSourceNode, 
  configSourceNode.toString()