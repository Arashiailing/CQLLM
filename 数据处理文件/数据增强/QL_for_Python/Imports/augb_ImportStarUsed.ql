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

// 导入Python分析模块，提供Python代码解析和分析的基础功能
import python

// 查找所有使用通配符导入的语句实例
from ImportStar starImport

// 输出结果：标记每个通配符导入并提供警告信息
select starImport, "Using 'from ... import *' pollutes the namespace and may hinder code analysis."