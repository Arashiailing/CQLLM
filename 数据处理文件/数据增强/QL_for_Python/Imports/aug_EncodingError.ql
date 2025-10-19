/**
 * @name Encoding error
 * @description 检测Python代码中的编码问题，这些问题可能导致程序运行时失败，
 *              并阻碍代码的静态分析。
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// 查找所有编码错误实例
from EncodingError encodingIssue

// 输出编码错误及其详细信息
select encodingIssue, encodingIssue.getMessage()