/**
 * @name Encoding error
 * @description 检测Python代码中可能导致运行时失败并阻碍静态分析的编码问题。
 *              这些问题通常涉及文件编码声明不匹配或字符串编码处理不当，
 *              可能导致程序在运行时出现UnicodeDecodeError等异常。
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// 查找所有与编码相关的问题实例
// 这些问题可能包括编码声明不一致、文件编码与内容不匹配等情况
from EncodingError encodingIssue

// 返回检测到的编码问题及其对应的错误消息
// 消息将提供关于问题的详细描述，帮助开发者理解并修复编码问题
select encodingIssue, encodingIssue.getMessage()