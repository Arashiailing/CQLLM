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

// 导入Python语言分析模块，提供Python代码的语法树构建、解析和错误检测功能
import python

// 查找所有Python语法错误实例，这些错误会导致代码无法正常解析和执行
from SyntaxError syntaxFailure
// 过滤条件：排除编码错误(EncodingError)，因为编码错误属于文件解析阶段的问题，
// 而非语法结构问题，需要单独处理
where not syntaxFailure instanceof EncodingError
// 输出结果：语法错误对象及其详细信息，附加当前Python主版本信息以便于问题定位
select syntaxFailure, syntaxFailure.getMessage() + " (in Python " + major_version() + ")."