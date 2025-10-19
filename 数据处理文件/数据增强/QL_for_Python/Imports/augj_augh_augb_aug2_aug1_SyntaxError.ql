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

// 引入Python语言分析模块，用于检测代码中的语法错误
import python

// 定义变量表示Python源代码中的语法错误
from SyntaxError syntaxIssue
where 
    // 排除编码错误，专注于语法结构问题
    not syntaxIssue instanceof EncodingError
// 输出语法错误详情及当前Python主版本信息
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."