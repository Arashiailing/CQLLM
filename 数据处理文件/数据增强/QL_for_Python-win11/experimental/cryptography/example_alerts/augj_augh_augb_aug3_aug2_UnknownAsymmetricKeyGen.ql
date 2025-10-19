/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 识别在非对称加密密钥创建过程中使用了无法通过静态分析确认的密钥尺寸的实例。
 *              这种情况可能导致系统采用弱密钥或不合规的密钥参数，从而增加安全漏洞风险。
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 本查询检测非对称密钥生成过程中的安全隐患：使用无法静态验证的密钥尺寸
// 此类隐患可能导致系统采用弱密钥或不合规密钥，增加被攻击的风险
from 
  AsymmetricKeyGen keyGenOperation,           // 表示非对称密钥生成操作
  DataFlow::Node keyParamSource,              // 表示密钥参数的来源节点
  string cryptoAlgorithm                     // 表示所使用的加密算法名称
where 
  // 确定密钥参数的来源节点
  keyParamSource = keyGenOperation.getKeyConfigSrc()
  and 
  // 获取使用的加密算法名称
  cryptoAlgorithm = keyGenOperation.getAlgorithm().getName()
  and 
  // 检查密钥生成操作是否缺少静态可验证的密钥尺寸
  not keyGenOperation.hasKeySize(keyParamSource)
select 
  keyGenOperation,
  // 构建告警信息，指明具体算法的密钥生成使用了无法静态验证的密钥尺寸
  "算法 " + cryptoAlgorithm.toString() + " 的密钥生成使用了无法静态验证的密钥尺寸，配置源位于 $@", 
  keyParamSource, 
  keyParamSource.toString()