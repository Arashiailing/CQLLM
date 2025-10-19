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

// 引入Python分析库，提供对Python代码结构的解析能力
import python

// 查找所有使用星号(*)通配符的导入语句
from ImportStar wildcardImport

// 报告所有通配符导入实例
select wildcardImport, "Using 'from ... import *' pollutes the namespace."