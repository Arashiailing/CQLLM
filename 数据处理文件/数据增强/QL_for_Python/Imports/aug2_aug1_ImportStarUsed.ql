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

// 导入Python代码分析库，提供对Python语法结构的解析能力
import python

// 识别所有使用星号(*)通配符的导入语句，这些语句会将模块的所有成员导入到当前命名空间
from ImportStar starImportStatement

// 报告所有通配符导入实例，并指出它们可能导致命名空间污染的问题
select starImportStatement, "Using 'from ... import *' pollutes the namespace."