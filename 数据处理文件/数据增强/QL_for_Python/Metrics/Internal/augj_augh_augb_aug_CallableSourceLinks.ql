/**
 * @name Python函数定义与源文件映射
 * @description 建立Python函数定义与其源代码文件之间的关联关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 检索所有Python函数并提取其源文件位置
from Function callableEntity, Location defLocation
where defLocation = callableEntity.getLocation()
select callableEntity, defLocation.getFile()