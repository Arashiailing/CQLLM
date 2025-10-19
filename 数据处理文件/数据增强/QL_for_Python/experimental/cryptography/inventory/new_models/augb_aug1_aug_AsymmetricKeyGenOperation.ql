/**
 * @name 非对称密钥生成识别
 * @description 检测代码库中通过标准加密库创建的非对称密钥实例。
 *              追踪密钥创建过程及其配置来源，以评估系统对量子计算风险的抵御能力。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义变量以表示非对称密钥创建操作及其配置来源
from AsymmetricKeyGen asymmetricKeyCreation, DataFlow::Node keyConfigurationOrigin
// 确保配置来源与密钥创建操作关联
where asymmetricKeyCreation.getKeyConfigSrc() = keyConfigurationOrigin
// 生成包含算法信息和配置来源的输出
select asymmetricKeyCreation,
  "使用算法 " + asymmetricKeyCreation.getAlgorithm().getName() +
    " 的非对称密钥创建，密钥配置源 $@", keyConfigurationOrigin, keyConfigurationOrigin.toString()