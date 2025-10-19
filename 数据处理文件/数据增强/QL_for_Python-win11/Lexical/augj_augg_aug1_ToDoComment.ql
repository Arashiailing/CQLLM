/**
 * @name Detection of incomplete task markers in comments
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

// 定义变量存储注释节点和其文本内容
from Comment todoComment, string commentContent

// 获取注释文本并检查是否包含待办事项标记
where 
  commentContent = todoComment.getText() and
  (
    commentContent.matches("%TODO%") or 
    commentContent.matches("%TO DO%")
  )

// 输出符合条件的注释节点及其文本内容
select 
  todoComment,
  commentContent