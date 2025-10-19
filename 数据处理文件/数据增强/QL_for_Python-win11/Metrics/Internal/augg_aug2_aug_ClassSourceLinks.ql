/**
 * @name 类的源链接
 * @description 识别并定位 Python 代码中定义的所有类，提供其源文件的完整路径信息
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历代码库中所有 Python 类定义
from Class pythonClass
// 确保类定义具有可获取的源位置信息
where exists(pythonClass.getLocation())
// 输出类对象及其对应的源文件完整路径，用于代码导航和依赖分析
select pythonClass, pythonClass.getLocation().getFile()