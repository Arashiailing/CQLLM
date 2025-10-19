/**
 * @name 'To Do' comment
 * @description Identifies comments containing 'TODO' or 'TO DO' markers. Such comments often
 *              indicate incomplete implementations or features that are pending development,
 *              which can accumulate and lead to technical debt if not properly managed.
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
  // 检查注释文本是否包含"TODO"或"TO DO"字符串
  todoComment.getText().matches("%TODO%") or 
  todoComment.getText().matches("%TO DO%")
select 
  todoComment,  // 选择符合条件的注释节点
  todoComment.getText()  // 及其文本内容