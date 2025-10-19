/**
 * @name 可调用对象的源代码链接
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 本查询用于识别Python代码库中的所有函数定义，并获取每个函数的源文件位置信息
// 这有助于开发者快速定位函数定义，进行代码审查、安全分析或维护工作
// 查询结果包含函数对象及其对应的源文件，可用于构建代码导航工具
from Function func
select 
  func, 
  func.getLocation().getFile()