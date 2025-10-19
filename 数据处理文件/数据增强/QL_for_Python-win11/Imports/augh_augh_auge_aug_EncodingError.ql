/**
 * @name Encoding error
 * @description 识别Python代码中可能引起运行时异常并妨碍静态分析的编码缺陷。
 *              此类问题通常源于文件编码声明与实际内容不符，或字符串编码操作不当，
 *              可能引发UnicodeDecodeError等运行时错误。
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// 识别Python代码中存在的所有编码问题
// 这些问题涵盖编码声明不匹配、文件编码与实际内容不符等多种情况
from EncodingError encodingProblem

// 输出检测到的编码问题及其相关描述信息
// 描述信息将详细说明问题性质，协助开发人员定位和解决编码问题
select encodingProblem, encodingProblem.getMessage()