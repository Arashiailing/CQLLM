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

// 引入Python语言分析模块，用于静态分析Python源代码结构
import python

// 检索所有使用通配符导入语法的代码位置
from ImportStar wildcardImport
// 报告检测结果，说明通配符导入会导致命名空间污染问题
select wildcardImport, "Using 'from ... import *' pollutes the namespace."