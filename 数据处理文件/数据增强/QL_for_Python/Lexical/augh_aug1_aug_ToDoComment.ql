/**
 * @name Unfinished task marker in comments
 * @description Detects comments containing 'TODO' or 'TO DO' markers, which indicate
 *              unfinished code segments that might proliferate in a codebase over time.
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

from Comment todoMarkerComment, string commentContent  // 从所有注释节点中选择变量todoMarkerComment，并声明commentContent变量
where 
  // 检查注释文本是否包含"TODO"或"TO DO"标记
  commentContent = todoMarkerComment.getText() and
  (commentContent.matches("%TODO%") or commentContent.matches("%TO DO%"))
select todoMarkerComment, commentContent  // 输出包含TODO标记的注释及其文本内容