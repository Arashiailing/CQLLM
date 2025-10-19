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

// 导入Python语言分析模块，提供对Python代码结构的访问能力
import python

// 识别所有使用通配符导入语法（from ... import *）的代码节点
from ImportStar starImport

// 输出检测到的通配符导入实例，并附带关于命名空间污染的警告信息
select starImport, "Using 'from ... import *' pollutes the namespace."