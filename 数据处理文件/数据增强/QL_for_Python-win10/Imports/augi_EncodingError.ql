/**
 * @name Encoding error
 * @description 当代码存在编码问题时，会引发运行时异常并妨碍静态分析。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// 查询所有编码错误实例及其相关消息
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()