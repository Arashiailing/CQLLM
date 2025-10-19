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

// 导入Python语言分析模块，提供代码静态分析的基础能力
import python

// 识别所有使用星号(*)通配符的导入语句，这种导入方式会将目标模块的所有公共符号
// 无差别地引入当前命名空间，可能导致命名冲突和代码可读性降低
from ImportStar namespacePollutingImport

// 报告检测到的通配符导入语句，并提示其对命名空间的潜在污染风险
select namespacePollutingImport, "Using 'from ... import *' pollutes the namespace."