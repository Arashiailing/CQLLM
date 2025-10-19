/**
 * @name 已知非对称密钥源生成
 * @description 识别在使用受支持的加密库时所有已知的潜在非对称密钥生成源，
 *              这些源可能对量子计算攻击构成风险。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作及其关联的配置源
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configSource
// 筛选条件：密钥生成操作的配置源必须匹配当前数据流节点
where keyGenOperation.getKeyConfigSrc() = configSource
// 输出结果：密钥生成操作、算法信息以及配置源详情
select keyGenOperation,
  "检测到使用算法 " + keyGenOperation.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置来源 $@", configSource, configSource.toString()