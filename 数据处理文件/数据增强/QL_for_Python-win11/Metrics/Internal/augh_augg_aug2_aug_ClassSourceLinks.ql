/**
 * @name Python 类源码位置追踪
 * @description 检索 Python 项目中所有已定义类的源文件路径，支持代码导航和依赖关系分析
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 从代码库中提取所有 Python 类定义及其位置信息
from Class cls, Location loc
// 确保类定义具有可获取的源位置信息
where loc = cls.getLocation()
// 输出类对象及其对应的源文件完整路径，用于代码导航和依赖分析
select cls, loc.getFile()