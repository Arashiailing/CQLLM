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

// 引入Python语言分析支持库，用于静态代码分析
import python

// 查找所有使用通配符导入语法（import *）的代码位置
// 这种导入方式会将所有名称导入当前命名空间，可能导致命名冲突
from ImportStar wildcardImport

// 报告所有通配符导入实例，并提示其会污染命名空间的问题
select wildcardImport, "Using 'from ... import *' pollutes the namespace."