/**
 * @name Encoding error
 * @description 检测代码中的编码问题，这些问题可能导致运行时异常并阻碍代码分析。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// 查找所有编码错误实例并获取其相关消息
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()