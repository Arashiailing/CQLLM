/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 识别在非对称加密算法中生成密钥时，密钥长度无法在静态分析阶段确定的安全漏洞
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 从非对称密钥生成操作中查找密钥大小无法静态确认的实例
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigSource, string cryptoAlgorithmName
where
  // 提取密钥配置的来源节点
  keyConfigSource = asymmetricKeyGeneration.getKeyConfigSrc() and
  // 获取加密算法的名称信息
  cryptoAlgorithmName = asymmetricKeyGeneration.getAlgorithm().getName() and
  // 验证密钥生成操作是否缺少静态可验证的密钥大小参数
  not asymmetricKeyGeneration.hasKeySize(keyConfigSource)
select asymmetricKeyGeneration,
  // 构建包含算法详情和配置源的漏洞报告
  "在算法 " + cryptoAlgorithmName.toString() + " 的密钥生成过程中，使用了无法静态验证的密钥大小，配置源自 $@", keyConfigSource, keyConfigSource.toString()