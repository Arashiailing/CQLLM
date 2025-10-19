/**
 * @name Multiple imports on one line
 * @description Defining multiple imports on one line makes code more difficult to read;
 *              PEP8 states that imports should usually be on separate lines.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

/*
 * 此查询用于识别在单行中导入多个模块的导入语句，
 * 这违反了PEP 8风格指南中每行一个导入的建议。
 */

// 导入Python库，用于解析和分析Python代码
import python

// 定义一个谓词，用于检查导入语句是否导入了多个模块
predicate isMultipleModuleImport(Import importStatement) { 
    // 检查导入语句是否包含多个模块名称
    count(importStatement.getAName()) > 1 and 
    // 确保导入不是"from ... import ..."样式的导入
    not importStatement.isFromImport() 
}

// 从所有导入语句中查找导入了多个模块的导入语句
from Import problematicImport
where isMultipleModuleImport(problematicImport)
select problematicImport, "Multiple imports on one line."