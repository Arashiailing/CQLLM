/**
 * @name Encoding error
 * @description 检测Python代码中可能导致运行时失败并阻碍静态分析的编码问题
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// 定位所有编码错误实例
from EncodingError encodingProblem

// 输出编码错误及其详细描述信息
select encodingProblem, encodingProblem.getMessage()