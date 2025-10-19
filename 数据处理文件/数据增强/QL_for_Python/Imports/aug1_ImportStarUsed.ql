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

// 引入Python分析库，用于检测Python代码中的模式
import python

// 查找所有使用通配符导入的实例
from ImportStar wildcardImport

// 输出结果：标记每个通配符导入，并提示其可能导致的命名空间污染问题
select wildcardImport, "Using 'from ... import *' pollutes the namespace."