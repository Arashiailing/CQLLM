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

// 引入Python分析库，提供对Python代码结构的解析支持
import python

// 检测所有使用星号(*)通配符的导入语句，这类导入会将模块的全部成员
// 引入当前命名空间，可能导致命名冲突和代码可读性问题
from ImportStar wildcardImport

// 报告所有通配符导入实例，提示开发者此类导入会导致命名空间污染
select wildcardImport, "Using 'from ... import *' pollutes the namespace."