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

// 导入Python标准库，提供对Python代码语法分析的支持
import python

// 查找所有语法错误实例，排除编码错误类型
from SyntaxError syntaxErr
where not syntaxErr instanceof EncodingError
select syntaxErr, syntaxErr.getMessage() + " (in Python " + major_version() + ")."
// 输出语法错误及其详细信息，包含当前Python主版本信息