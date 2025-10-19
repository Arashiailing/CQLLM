/**
 * @name 'import *' used
 * @description Identifies usage of wildcard imports that can hinder static analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// 加载Python代码分析库，提供对Python语法树和代码结构的访问能力
import python

// 检索所有使用星号(*)通配符的导入语句，这些语句将整个模块的内容导入当前命名空间
from ImportStar wildcardImport

// 报告每个检测到的通配符导入实例，并指出它们可能导致的命名空间污染和代码可维护性问题
select wildcardImport, "Usage of 'from ... import *' may cause namespace pollution."