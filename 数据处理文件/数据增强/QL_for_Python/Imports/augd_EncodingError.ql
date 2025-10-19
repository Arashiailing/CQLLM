/**
 * @name Encoding error
 * @description 检测Python代码中的编码问题，这类问题会在程序执行时引发异常，
 *              干扰正常运行流程，并可能阻碍静态分析工具的完整解析。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// 查询所有编码错误实例并获取对应的错误信息
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()