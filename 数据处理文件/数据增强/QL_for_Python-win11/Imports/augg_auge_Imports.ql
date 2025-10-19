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
 * 此查询检测违反PEP 8规范的导入语句：
 * 识别在同一行中导入多个模块的非from-import语句
 */

// 导入Python分析库，提供代码解析基础能力
import python

// 查找所有存在多模块导入问题的语句
from Import violation
where
  // 条件1：导入语句包含多个模块名称
  count(violation.getAName()) > 1 and
  // 条件2：排除"from ... import ..."语法结构
  not violation.isFromImport()
select violation, "Multiple imports on one line."