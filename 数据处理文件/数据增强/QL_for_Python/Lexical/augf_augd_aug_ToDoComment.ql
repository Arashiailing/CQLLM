/**
 * @name 'To Do' comment
 * @description Detects comments that include 'TODO' or 'TO DO' indicators. These markers
 *              typically signify unfinished work or pending tasks that need attention,
 *              and excessive presence can negatively affect code quality and maintenance.
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

from Comment todoComment  // 从所有注释节点中选择变量todoComment
where 
  // 检查注释文本是否包含"TODO"或"TO DO"标记
  todoComment.getText().matches("%TODO%") or 
  todoComment.getText().matches("%TO DO%")
select todoComment, todoComment.getText()  // 输出包含TODO标记的注释及其文本内容