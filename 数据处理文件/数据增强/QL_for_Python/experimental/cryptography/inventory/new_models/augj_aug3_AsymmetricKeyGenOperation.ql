/**
 * @name 非对称密钥生成源识别
 * @description 识别代码中使用受支持库生成的非对称密钥及其配置来源。
 *              分析非对称密钥生成操作与配置数据流，定位密钥管理漏洞
 *              和安全风险点，支持密码学资产清单(CBOM)构建。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 识别非对称密钥生成操作及其配置数据流源
// 通过关联密钥生成操作与配置数据流节点，建立密钥溯源链路
from AsymmetricKeyGen asymKeyGen, DataFlow::Node configSourceNode
where asymKeyGen.getKeyConfigSrc() = configSourceNode
select asymKeyGen,
  "检测到非对称密钥生成，使用算法: " + asymKeyGen.getAlgorithm().getName() +
    "，密钥配置源: $@", configSourceNode, configSourceNode.toString()