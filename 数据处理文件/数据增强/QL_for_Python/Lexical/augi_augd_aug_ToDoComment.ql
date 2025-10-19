/**
 * @name 'To Do' comment
 * @description Detects comments containing 'TODO' or 'TO DO' markers. These markers
 *              typically indicate unfinished features or pending tasks that require
 *              attention. Accumulation of such markers may negatively affect code
 *              maintainability and technical debt management.
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
  todoComment.getText().matches("%(TODO|TO DO)%")
select todoComment, todoComment.getText()  // 输出包含TODO标记的注释及其文本内容