/**
 * @name File is not always closed
 * @description Opening a file without ensuring that it is always closed may lead to data loss or resource leaks.
 * @kind problem
 * @tags efficiency
 *       correctness
 *       resources
 *       quality
 *       external/cwe/cwe-772
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/file-not-closed
 */

// 导入Python库，用于处理Python代码的查询
import python

// 导入FileNotAlwaysClosedQuery模块，该模块包含文件未关闭相关的查询逻辑
import FileNotAlwaysClosedQuery

// 从FileOpen类和字符串类型中选择数据
from FileOpen fo, string msg
where
  // 检查文件是否未被关闭
  fileNotClosed(fo) and
  // 如果文件未被关闭，设置消息为"File is opened but is not closed."
  msg = "File is opened but is not closed."
  or
  // 检查在异常情况下文件可能未被关闭
  fileMayNotBeClosedOnException(fo, _) and
  // 如果文件在异常情况下可能未被关闭，设置消息为"File may not be closed if an exception is raised."
  msg = "File may not be closed if an exception is raised."
// 选择文件对象和对应的消息进行输出
select fo, msg
