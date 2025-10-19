/**
 * @name 类的源链接
 * @description 查找 Python 代码中所有类的源文件位置
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

/* 
 * 查询分析：
 * - 遍历代码库中的所有 Python 类定义
 * - 提取每个类定义的源文件位置信息
 * - 输出类对象及其对应的源文件路径
 * 用途：帮助开发者快速定位类定义位置，便于代码审查和维护
 */
from Class classDefinition
// 从类定义的位置信息中提取源文件路径
select classDefinition, classDefinition.getLocation().getFile()