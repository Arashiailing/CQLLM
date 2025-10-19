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

// 引入Python分析库，提供代码分析所需的基础类和谓词
import python

// 查找所有使用通配符导入语法（import *）的语句
// 这种导入方式会将目标模块的所有公共成员导入当前命名空间
from ImportStar wildcardImport

// 输出检测结果：标记每个通配符导入语句并提供风险提示
// 警告信息说明这种导入方式会导致命名空间污染问题
select wildcardImport, "Using 'from ... import *' pollutes the namespace."