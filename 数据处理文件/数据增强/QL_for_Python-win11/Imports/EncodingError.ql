/**
 * @name Encoding error
 * @description 编码错误会导致运行时失败，并阻止代码的分析。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// 从 EncodingError 类中选择错误和错误消息
from EncodingError error
select error, error.getMessage()
