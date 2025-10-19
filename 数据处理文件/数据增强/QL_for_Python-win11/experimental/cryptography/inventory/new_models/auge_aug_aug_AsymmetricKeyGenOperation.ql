/**
 * @name 非对称密钥生成及配置源追踪
 * @description 检测代码库中通过加密库生成的非对称密钥。
 *              追踪密钥生成操作及其配置来源，评估系统对量子计算威胁的抵御能力。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 识别非对称密钥生成操作及其配置来源
from AsymmetricKeyGen asymKeyGen,
     // 获取密钥配置源节点
     DataFlow::Node keyConfigSrc
// 关联密钥生成操作与配置源
where asymKeyGen.getKeyConfigSrc() = keyConfigSrc
// 输出结果：密钥生成操作、算法信息及配置源
select asymKeyGen,
  "使用算法 " + asymKeyGen.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置源 $@", keyConfigSrc, keyConfigSrc.toString()