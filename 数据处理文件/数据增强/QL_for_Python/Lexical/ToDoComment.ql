/**
 * @name 'To Do' comment
 * @description Writing comments that include 'TODO' tends to lead to a build up of partially
 *              implemented features.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 *       external/cwe/cwe-546
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/todo-comment
 */

import python  # 导入Python语言库，用于分析Python代码

from Comment c  # 从所有注释节点中选择变量c
where c.getText().matches("%TODO%") or c.getText().matches("%TO DO%")  # 过滤条件：匹配包含"TODO"或"TO DO"的注释文本
select c, c.getText()  # 选择符合条件的注释节点及其文本内容
