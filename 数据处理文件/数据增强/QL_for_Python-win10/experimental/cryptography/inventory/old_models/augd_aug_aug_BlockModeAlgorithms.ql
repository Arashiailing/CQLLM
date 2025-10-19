/**
 * @name 分组密码工作模式识别
 * @description 检测代码中使用的加密算法所采用的分组密码工作模式。
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 引入Python分析所需的库和密码学相关概念
import python
import semmle.python.Concepts

// 声明变量用于表示加密操作实例及其对应的工作模式
from Cryptography::CryptographicOperation cipherOperation, string blockMode

// 验证加密操作确实具有分组工作模式属性
where blockMode = cipherOperation.getBlockMode()

// 输出检测结果，包括加密操作对象及其工作模式信息
select 
  cipherOperation, 
  "发现使用分组密码工作模式的加密算法: " + blockMode