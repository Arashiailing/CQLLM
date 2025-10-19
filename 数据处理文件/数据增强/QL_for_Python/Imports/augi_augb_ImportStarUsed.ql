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

// 导入Python分析引擎，提供代码解析和语义分析的基础能力
import python

// 检测代码中所有使用通配符导入语法（import *）的实例
from ImportStar wildcardImportStmt

// 生成报告，标记每个通配符导入位置并解释其对代码质量和分析工具的负面影响
select wildcardImportStmt, "Usage of 'from ... import *' introduces namespace pollution and may impede static analysis tools."