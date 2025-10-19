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

// 导入Python语言分析模块，提供语法错误检测功能
import python

// 查询所有非编码类型的语法错误
from SyntaxError syntaxIssue
where 
    // 排除编码相关的错误，只关注真正的语法问题
    not syntaxIssue instanceof EncodingError
// 返回语法错误及其详细信息，包含当前Python主版本信息
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."