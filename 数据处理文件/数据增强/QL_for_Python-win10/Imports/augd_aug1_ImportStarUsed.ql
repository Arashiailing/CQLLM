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

// 导入Python代码分析库，用于识别代码中的特定模式
import python

// 识别所有使用了通配符导入语法（import *）的代码位置
// 这种导入方式会将目标模块的所有公共成员导入当前命名空间
from ImportStar starImportStmt

// 输出检测结果：标记每个通配符导入语句并提示相关风险
// 警告信息说明这种导入方式会导致命名空间污染问题
select starImportStmt, "Using 'from ... import *' pollutes the namespace."