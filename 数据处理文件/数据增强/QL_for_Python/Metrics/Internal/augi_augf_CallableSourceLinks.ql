/**
 * @name 可调用对象的源代码链接
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 此查询旨在发现Python项目中的所有函数定义，并提取它们在源代码中的文件位置
// 该功能对代码审计、安全漏洞分析以及日常维护工作具有重要价值
// 输出结果包含函数对象及其源文件引用，可用于开发代码索引和导航系统
from Function callableObj
select 
  callableObj, 
  callableObj.getLocation().getFile() as sourceFile