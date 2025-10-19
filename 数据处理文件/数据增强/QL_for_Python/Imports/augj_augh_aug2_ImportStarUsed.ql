/**
 * @name 'import *' used
 * @description Detects usage of wildcard imports which can hinder static analysis
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// 导入Python分析库，提供静态代码分析所需的基础功能
import python

// 识别所有采用通配符导入（import *）的代码节点
// 这种导入方式会将模块中的所有公共名称引入当前作用域，可能导致命名空间污染
from ImportStar namespacePollutingImport

// 输出检测结果，提示通配符导入对命名空间的潜在污染风险
select namespacePollutingImport, "Using 'from ... import *' pollutes the namespace."