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

// 导入Python语言分析库，支持静态代码扫描和分析
import python

// 检索所有使用星号导入语法的代码位置
// 此类导入会将所有符号导入当前作用域，可能导致命名冲突
from ImportStar starImport

// 输出所有星号导入实例及其相关问题描述
select starImport, "Using 'from ... import *' pollutes the namespace."