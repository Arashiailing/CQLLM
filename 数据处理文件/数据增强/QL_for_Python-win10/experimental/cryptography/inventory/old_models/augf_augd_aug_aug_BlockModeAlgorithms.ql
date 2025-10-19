/**
 * @name 分组密码工作模式识别
 * @description 识别代码中加密算法所采用的分组密码工作模式，帮助评估加密实现的安全性。
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python分析所需的库和密码学相关概念
import python
import semmle.python.Concepts

// 定义变量：cryptoOp表示加密操作，modeOfOperation表示分组密码工作模式
from Cryptography::CryptographicOperation cryptoOp, string modeOfOperation

// 筛选条件：确保加密操作具有分组密码工作模式属性
where modeOfOperation = cryptoOp.getBlockMode()

// 输出检测结果，包括加密操作对象及其分组密码工作模式
select 
  cryptoOp, 
  "检测到使用分组密码工作模式的加密实现: " + modeOfOperation