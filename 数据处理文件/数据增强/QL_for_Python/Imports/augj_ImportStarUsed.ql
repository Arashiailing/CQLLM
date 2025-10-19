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

// 导入Python分析模块，提供代码分析所需的基础类和谓词
import python

// 查找所有使用通配符导入语法（import *）的Python语句
from ImportStar wildcardImportStatement
// 输出检测结果：每个通配符导入都会触发一个命名空间污染警告
select wildcardImportStatement, "Using 'from ... import *' pollutes the namespace."