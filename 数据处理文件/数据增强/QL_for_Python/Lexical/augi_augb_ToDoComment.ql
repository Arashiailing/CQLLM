/**
 * @name 'To Do' comment detection
 * @description Finds code comments that include 'TODO' or 'TO DO' markers, which usually signify
 *              unfinished functionality or temporary code that requires future attention.
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

import python  // 导入Python语言库，用于分析Python代码

from Comment commentWithTodo  // 从所有注释节点中选择变量commentWithTodo
where exists(string text | text = commentWithTodo.getText() and text.matches("%(TODO|TO DO)%"))  // 过滤条件：检查注释文本是否存在并匹配包含"TODO"或"TO DO"的模式
select commentWithTodo, commentWithTodo.getText()  // 选择符合条件的注释节点及其文本内容