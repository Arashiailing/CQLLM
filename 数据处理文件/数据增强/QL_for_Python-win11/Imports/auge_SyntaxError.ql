/**
 * @name Syntax error
 * @description Detects syntax errors that lead to runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// 引入Python分析模块，提供Python代码查询所需的基础功能
import python

// 查找所有语法错误实例，排除编码相关的错误类型
from SyntaxError syntaxIssue
where 
  not syntaxIssue instanceof EncodingError
select 
  syntaxIssue, 
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."
// 输出语法错误详情及关联的Python主版本信息