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

// 加载Python语言分析模块，启用语法错误检测能力
import python

// 识别所有非编码类型的语法错误
from SyntaxError syntaxError
where 
    // 过滤掉编码错误，专注于纯粹的语法问题
    not syntaxError instanceof EncodingError
// 输出语法错误及其描述信息，附带当前Python主版本号
select 
    syntaxError, 
    // 构建包含错误消息和Python版本信息的描述
    syntaxError.getMessage() + " (in Python " + major_version() + ")."