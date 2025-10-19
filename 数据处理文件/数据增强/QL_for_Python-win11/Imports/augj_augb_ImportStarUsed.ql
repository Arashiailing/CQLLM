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

// 引入Python代码分析模块，提供基础解析和分析能力
import python

// 识别所有采用通配符导入语法的代码位置
from ImportStar wildcardImport

// 输出检测结果：标记每个通配符导入实例并提供相关警告信息
select wildcardImport, "Using 'from ... import *' pollutes the namespace and may hinder code analysis."