/**
 * @name 'To Do' comment detection
 * @description Identifies comments containing 'TODO' or 'TO DO' markers which indicate
 *              incomplete features or pending tasks in the codebase.
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

from Comment todoComment  // 从所有注释节点中选择变量todoComment
where 
  // 过滤条件：匹配包含"TODO"或"TO DO"的注释文本
  todoComment.getText().matches("%TODO%") or 
  todoComment.getText().matches("%TO DO%")
select 
  todoComment,  // 选择符合条件的注释节点
  todoComment.getText()  // 及其文本内容