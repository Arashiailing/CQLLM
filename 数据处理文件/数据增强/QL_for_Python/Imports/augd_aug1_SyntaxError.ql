/**
 * @name Syntax error
 * @description Detects syntax errors in Python code that can cause runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// 引入Python分析模块，提供语法分析相关功能
import python

// 识别Python代码中的语法错误，但排除编码相关的错误类型
from SyntaxError syntaxIssue
where not syntaxIssue instanceof EncodingError
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."
// 展示语法错误详情，包括错误消息和当前Python主版本号