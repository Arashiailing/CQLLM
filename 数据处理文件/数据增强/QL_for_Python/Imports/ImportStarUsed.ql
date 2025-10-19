/**
 * @name 'import *' used
 * @description Using import * prevents some analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// 导入Python模块，用于分析Python代码
import python

// 从ImportStar类中选择实例i
from ImportStar i
// 查询语句：选择i并输出警告信息，指出使用'from ... import *'会污染命名空间。
select i, "Using 'from ... import *' pollutes the namespace."
