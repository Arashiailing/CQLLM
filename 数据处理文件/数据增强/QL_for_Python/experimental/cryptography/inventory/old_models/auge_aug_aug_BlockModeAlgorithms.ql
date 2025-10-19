/**
 * @name 分组密码工作模式检测
 * @description 检测加密库中使用的分组密码工作模式，以评估密码实现的安全性。
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python分析所需的核心库和密码学相关概念
import python
import semmle.python.Concepts

// 从密码操作中提取具有分组模式的信息
from Cryptography::CryptographicOperation cipherOperation, string encryptionMode

// 筛选条件：仅考虑已定义分组模式的密码操作
where 
  encryptionMode = cipherOperation.getBlockMode()

// 输出检测结果，包括密码操作对象和相应的分组模式信息
select 
  cipherOperation, 
  "检测到具有分组模式的算法: " + encryptionMode