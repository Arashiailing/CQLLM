/**
 * @name 类的源链接
 * @description 查找 Python 代码中所有类的源文件位置
 * @details 此查询扫描项目中的所有 Python 类定义，并返回每个类及其对应的源文件路径。
 *          通过提供类与源文件的映射关系，开发人员可以快速定位类的定义位置，
 *          这对于代码审查、重构和维护工作非常有帮助。
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查询所有 Python 类定义
from Class clsDef
// 提取类定义的源文件路径
select clsDef, clsDef.getLocation().getFile()