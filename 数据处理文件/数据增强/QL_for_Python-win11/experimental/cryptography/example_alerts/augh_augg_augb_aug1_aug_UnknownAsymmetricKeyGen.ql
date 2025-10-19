/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 检测非对称加密算法密钥生成过程中密钥长度无法静态确定的安全风险
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作中密钥大小无法静态确认的情况
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keySizeSource, string algorithmName
where
  // 获取密钥配置的来源节点
  keySizeSource = keyGenOperation.getKeyConfigSrc() and
  // 提取加密算法名称
  algorithmName = keyGenOperation.getAlgorithm().getName() and
  // 确认密钥生成操作是否缺少静态可验证的密钥大小参数
  not keyGenOperation.hasKeySize(keySizeSource)
select keyGenOperation,
  // 构建包含算法详情和配置源的漏洞报告
  "在算法 " + algorithmName.toString() + " 的密钥生成过程中，使用了无法静态验证的密钥大小，配置源自 $@", keySizeSource, keySizeSource.toString()