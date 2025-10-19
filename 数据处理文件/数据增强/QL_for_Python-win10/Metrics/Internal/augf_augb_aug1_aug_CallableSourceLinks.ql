/**
 * @name Python可调用对象源文件定位
 * @description 映射Python函数/方法到其定义所在的源文件
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 * 
 * 此查询遍历代码库中的所有Python函数，并建立它们与定义源文件之间的映射关系。
 * 结果集包含每个函数对象及其对应的源文件完整路径。
 */

import python

// 遍历所有Python函数定义，提取其源文件位置信息
from Function funcDef, File sourceFile
where sourceFile = funcDef.getLocation().getFile()
select funcDef, sourceFile