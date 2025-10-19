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

// 导入Python分析模块，提供Python代码的静态分析能力
import python

// 识别所有使用通配符导入的语句实例
from ImportStar starImport
// 输出检测结果和警告信息，提示通配符导入会污染命名空间
select starImport, "Using 'from ... import *' pollutes the namespace."