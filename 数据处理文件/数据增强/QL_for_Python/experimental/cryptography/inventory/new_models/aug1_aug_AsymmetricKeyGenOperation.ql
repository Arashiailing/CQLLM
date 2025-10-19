/**
 * @name 已知非对称密钥源生成
 * @description 识别代码库中通过受支持的加密库生成的非对称密钥实例。
 *              追踪密钥生成操作及其配置来源，用于评估系统对量子计算威胁的防御能力。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 检索所有非对称密钥生成操作及其关联的配置来源节点
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configSourceNode
where keyGenOperation.getKeyConfigSrc() = configSourceNode
// 构建包含算法名称和配置来源的描述信息
select keyGenOperation,
  "使用算法 " + keyGenOperation.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置源 $@", configSourceNode, configSourceNode.toString()