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

// 引入Python语言分析模块，提供语法错误检测能力
import python

// 识别所有非编码类型的语法错误
from SyntaxError syntaxFault
where not syntaxFault instanceof EncodingError
// 输出语法错误及其详细信息，包含当前Python主版本信息
select syntaxFault, syntaxFault.getMessage() + " (in Python " + major_version() + ")."