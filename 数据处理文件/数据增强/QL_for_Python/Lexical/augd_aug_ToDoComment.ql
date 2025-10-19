/**
 * @name 'To Do' comment
 * @description Identifies comments containing 'TODO' or 'TO DO' markers. Such comments
 *              often represent incomplete features or tasks that should be addressed,
 *              and their accumulation can impact code maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/todo-comment
 */

import python  // 导入Python语言库，用于分析Python代码

from Comment commentWithTodo  // 从所有注释节点中选择变量commentWithTodo
where 
  // 检查注释文本是否包含"TODO"或"TO DO"标记
  commentWithTodo.getText().matches("%TODO%") or 
  commentWithTodo.getText().matches("%TO DO%")
select commentWithTodo, commentWithTodo.getText()  // 输出包含TODO标记的注释及其文本内容