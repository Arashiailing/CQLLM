/**
 * @name Encoding error
 * @description 检测Python代码中可能导致运行时失败并阻碍静态分析的编码问题。
 *              这包括文件编码声明与实际内容不匹配、字符串编码不一致等情况。
 *              这些问题可能导致程序在运行时抛出异常或产生不正确的结果。
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// 查询定义：识别所有编码相关的错误
// EncodingError 类代表代码中可能存在的编码问题，如文件编码声明错误等
from EncodingError encodingIssue

// 结果输出：每个编码错误及其详细描述
// 输出格式：错误实例, 错误描述信息
// 这有助于开发者快速定位和理解编码问题
select encodingIssue, encodingIssue.getMessage()