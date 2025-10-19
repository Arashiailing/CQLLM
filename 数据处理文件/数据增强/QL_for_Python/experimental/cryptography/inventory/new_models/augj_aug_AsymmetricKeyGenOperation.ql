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
from AsymmetricKeyGen keyGenOp, DataFlow::Node configSrc
where 
  // 确保配置源与密钥生成操作相关联
  keyGenOp.getKeyConfigSrc() = configSrc
select 
  keyGenOp,
  // 构建描述性消息，包含算法名称和配置源引用
  "使用算法 " + keyGenOp.getAlgorithm().getName() + " 的非对称密钥生成，密钥配置源 $@", 
  configSrc, 
  configSrc.toString()