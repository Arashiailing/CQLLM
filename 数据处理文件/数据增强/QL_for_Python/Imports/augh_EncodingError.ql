/**
 * @name Encoding error
 * @description 检测代码中可能存在的编码错误，这些错误会导致程序在运行时失败，
 *              并可能阻碍代码分析工具的正常工作。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// 定义查询源：识别所有编码错误实例
from EncodingError encodingIssue

// 返回结果：编码错误对象及其对应的错误信息
select encodingIssue, encodingIssue.getMessage()