/**
 * @name 类的源链接
 * @description 查找 Python 代码中所有类的源文件位置
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历所有 Python 类定义
from Class pythonCls
// 提取类对象及其源文件路径
select pythonCls, pythonCls.getLocation().getFile()