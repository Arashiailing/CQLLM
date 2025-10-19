/**
 * @name Python函数源文件映射
 * @description 建立Python函数与其源代码文件之间的关联关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 查询所有Python函数定义，并获取每个函数在源代码中的位置信息
// 通过函数的位置信息进一步定位到函数所在的源文件
from Function funcDef, Location codeLocation
where codeLocation = funcDef.getLocation()
select funcDef, codeLocation.getFile()