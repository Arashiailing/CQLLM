/**
 * @name Missing part of special group in regular expression
 * @description Incomplete special groups are parsed as normal groups and are unlikely to match the intended strings.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/regex/incomplete-special-group
 */

import python  // 导入python模块，用于分析Python代码
import semmle.python.regex  // 导入semmle.python.regex模块，用于处理正则表达式相关的查询

// 定义一个查询，从RegExp对象r、字符串missing和字符串part中选择数据
from RegExp r, string missing, string part
// 条件：正则表达式文本匹配包含"P<word>"的模式，并且missing等于"?"，part等于"named group"
where r.getText().regexpMatch(".*\\(P<\\w+>.*") and missing = "?" and part = "named group"
// 选择结果：返回正则表达式对象r，并生成警告信息
select r, "Regular expression is missing '" + missing + "' in " + part + "."
