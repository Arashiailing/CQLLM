/**
 * @name Syntax error
 * @description Detects syntax errors in Python code that lead to runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// 导入Python语言分析模块，用于检测代码中的语法错误
import python

// 查询所有非编码相关的语法错误
from SyntaxError syntaxIssue
where not syntaxIssue instanceof EncodingError
// 返回语法错误及其描述信息，并附带当前Python主版本号
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."