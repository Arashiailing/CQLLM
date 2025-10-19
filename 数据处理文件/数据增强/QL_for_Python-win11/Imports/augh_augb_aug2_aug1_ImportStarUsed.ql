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

// 导入Python语言分析模块，提供静态分析所需的基础类型和谓词支持
import python

// 识别所有使用星号(*)通配符语法的导入语句，这些语句会将目标模块的所有公共符号
// 无差别地导入到当前命名空间中，可能导致符号冲突和代码可读性降低
from ImportStar namespacePollutingImport

// 报告检测到的通配符导入语句，并提示其对命名空间造成的潜在污染问题
select namespacePollutingImport, "Using 'from ... import *' pollutes the namespace."