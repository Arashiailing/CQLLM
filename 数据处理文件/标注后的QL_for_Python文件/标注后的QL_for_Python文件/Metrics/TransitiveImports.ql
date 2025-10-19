/**
 * @name Indirect imports per file
 * @description The number of modules imported by this file - either directly by an import statement,
 *              or indirectly (by being imported by an imported module).
 * @kind treemap
 * @id py/transitive-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 从ModuleValue类中获取模块m，以及整数n
from ModuleValue m, int n
// 条件：n等于通过递归调用m.getAnImportedModule()方法得到的模块数量，并且这些模块不等于m自身
where n = count(ModuleValue imp | imp = m.getAnImportedModule+() and imp != m)
// 选择模块m的作用域和计算得到的间接导入数量n
select m.getScope(), n
