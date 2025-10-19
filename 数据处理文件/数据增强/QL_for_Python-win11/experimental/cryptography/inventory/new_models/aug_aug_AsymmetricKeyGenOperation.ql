/**
 * @name 非对称密钥生成及配置源追踪
 * @description 检测代码库中通过受支持的加密库生成的非对称密钥。
 *              本查询追踪密钥生成操作及其配置来源，以评估系统对量子计算威胁的抵御能力。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 识别非对称密钥生成操作
from AsymmetricKeyGen keyGenOperation,
     // 获取密钥配置来源节点
     DataFlow::Node configSource
// 关联密钥生成操作与配置源
where keyGenOperation.getKeyConfigSrc() = configSource
// 输出结果：密钥生成操作、算法信息及配置源
select keyGenOperation,
  "使用算法 " + keyGenOperation.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置源 $@", configSource, configSource.toString()