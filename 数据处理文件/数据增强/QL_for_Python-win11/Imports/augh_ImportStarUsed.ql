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

// 引入Python分析库，提供Python代码分析所需的基础类和谓词
import python

// 定义变量wildcardImport，代表所有使用通配符*的导入语句
from ImportStar wildcardImport
// 输出查询结果：标识通配符导入并提示其可能带来的命名空间污染问题
select wildcardImport, "Using 'from ... import *' pollutes the namespace."