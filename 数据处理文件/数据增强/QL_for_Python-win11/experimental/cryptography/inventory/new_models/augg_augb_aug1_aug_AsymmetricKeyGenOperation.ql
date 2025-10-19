/**
 * @name 非对称密钥生成检测
 * @description 识别通过标准加密库实例化的非对称密钥对象。
 *              跟踪密钥生成过程及其参数来源，以评估系统对量子计算威胁的防护能力。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 检索所有非对称密钥生成操作及其配置参数来源
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configSource
// 确保密钥生成操作与配置来源之间存在关联
where keyGenOperation.getKeyConfigSrc() = configSource
// 生成包含算法信息和配置来源的查询结果
select keyGenOperation,
  "使用算法 " + keyGenOperation.getAlgorithm().getName() +
    " 的非对称密钥生成，配置来源 $@", configSource, configSource.toString()