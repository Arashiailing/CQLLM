/**
 * @name Task marker comment detection
 * @description Detects comments containing 'TODO' or 'TO DO' markers that signify
 *              unfinished functionality or tasks requiring attention in the codebase.
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

from Comment taskMarkerComment  // 从所有注释节点中选择变量taskMarkerComment
where 
  // 定义包含任务标记的注释文本匹配模式
  exists(string commentText | 
    commentText = taskMarkerComment.getText() and
    (
      commentText.matches("%TODO%") or 
      commentText.matches("%TO DO%")
    )
  )
select 
  taskMarkerComment,  // 选择符合条件的注释节点
  taskMarkerComment.getText()  // 及其文本内容