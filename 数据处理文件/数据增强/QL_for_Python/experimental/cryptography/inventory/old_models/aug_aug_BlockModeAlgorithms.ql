/**
 * @name 分组密码工作模式检测
 * @description 识别在支持的加密库中可能使用的分组密码工作模式。
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入必要的Python库和Semmle Python概念以进行密码分析
import python
import semmle.python.Concepts

// 定义变量以存储密码操作和分组模式名称
from Cryptography::CryptographicOperation cryptoOperation, string modeName

// 确保密码操作具有分组模式
where 
  modeName = cryptoOperation.getBlockMode()

// 选择密码操作及其分组模式
select 
  cryptoOperation, 
  "检测到具有分组模式的算法: " + modeName