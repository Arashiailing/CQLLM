/**
 * @name 已知非对称密钥源生成
 * @description 在支持的加密库中识别所有潜在的非对称密钥生成源点，
 *              这些源点容易受到量子计算攻击的威胁。
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-key-generation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义查询变量：非对称密钥生成操作及其配置源
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigOrigin
// 应用过滤条件：确保配置源与密钥生成操作相关联
where asymmetricKeyGeneration.getKeyConfigSrc() = keyConfigOrigin
// 生成结果：报告密钥生成操作、算法信息和配置源详情
select asymmetricKeyGeneration,
  "检测到使用算法 " + asymmetricKeyGeneration.getAlgorithm().getName() +
    " 的非对称密钥生成，密钥配置来源 $@", keyConfigOrigin, keyConfigOrigin.toString()