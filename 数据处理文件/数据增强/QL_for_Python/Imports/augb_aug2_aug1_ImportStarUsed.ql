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

// 引入Python语言分析模块，为代码分析提供基础支持
import python

// 查找所有采用星号(*)通配符语法的导入声明，这类导入会将目标模块的全部符号引入当前作用域
from ImportStar wildcardImport

// 输出检测到的通配符导入语句，并提示其可能导致的命名空间污染风险
select wildcardImport, "Using 'from ... import *' pollutes the namespace."