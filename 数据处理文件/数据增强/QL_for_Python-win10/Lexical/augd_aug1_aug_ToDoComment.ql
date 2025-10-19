/**
 * @name Detection of unfinished task markers in source code comments
 * @description Finds comments containing 'TODO' or 'TO DO' markers, which usually indicate
 *              incomplete code segments that can accumulate in a codebase over time.
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

from Comment todoMarkerComment  // 从所有注释节点中选择变量todoMarkerComment
where 
  // 检查注释文本是否包含"TODO"或"TO DO"标记
  todoMarkerComment.getText().matches("%TODO%") or
  todoMarkerComment.getText().matches("%TO DO%")
select todoMarkerComment, todoMarkerComment.getText()  // 输出包含TODO标记的注释及其文本内容