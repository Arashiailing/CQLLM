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

// 导入Python语言分析模块，提供语法错误检测能力
import python

// 查找Python代码中的语法错误问题
from SyntaxError pySyntaxError
where 
    // 过滤掉编码相关的错误，专注于真正的语法问题
    not pySyntaxError instanceof EncodingError
// 输出语法错误及其详细信息，并附加当前Python主版本信息
select pySyntaxError, pySyntaxError.getMessage() + " (in Python " + major_version() + ")."