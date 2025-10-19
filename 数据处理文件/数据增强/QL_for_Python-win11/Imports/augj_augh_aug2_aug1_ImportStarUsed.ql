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

// 导入Python分析库，提供对Python代码结构的解析支持
import python

// 定义变量表示所有星号通配符导入语句
from ImportStar starImportStmt

// 报告所有通配符导入实例，说明其污染命名空间的危害
select starImportStmt, "Using 'from ... import *' pollutes the namespace."