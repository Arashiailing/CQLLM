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

// 导入Python库，用于处理Python代码的查询和分析
import python

// 从SyntaxError类中选择错误实例，但不包括EncodingError类型的错误
from SyntaxError error
where not error instanceof EncodingError
select error, error.getMessage() + " (in Python " + major_version() + ")."
// 选择语法错误实例以及错误信息，并附加当前Python主版本号
