/**
 * @name 块密码模式中未初始化的向量或随机数
 * @description 识别在块密码操作中未正确配置初始化向量(IV)或nonce的代码实例，此类配置缺失可能导致安全漏洞
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 获取所有块密码模式的使用实例
from BlockMode cipherModeInstance
// 过滤出未设置IV或nonce参数的实例
where 
  not cipherModeInstance.hasIVorNonce()
// 报告存在安全风险的块模式实例并提供相关描述
select 
  cipherModeInstance, 
  "Block mode with unknown IV or Nonce configuration"