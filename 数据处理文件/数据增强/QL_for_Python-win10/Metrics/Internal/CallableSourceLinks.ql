/**
 * @name 可调用对象的源代码链接
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 从函数 `f` 中选择函数对象和其源文件位置
from Function f
select f, f.getLocation().getFile()
