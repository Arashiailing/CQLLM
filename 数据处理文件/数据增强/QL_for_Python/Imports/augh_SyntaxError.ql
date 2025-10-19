/**
 * @name Syntax error
 * @description Syntax errors cause failures at runtime and prevent analysis of the code.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// 导入Python分析模块，提供Python代码的语法分析和错误检测功能
import python

// 查找所有Python语法错误，排除编码错误
from SyntaxError syntaxErr
where 
  // 确保错误不是编码错误（EncodingError的实例）
  not syntaxErr instanceof EncodingError
select 
  // 输出语法错误对象及其详细信息
  syntaxErr, 
  // 构建错误消息，包含当前Python主版本号
  syntaxErr.getMessage() + " (in Python " + major_version() + ")."