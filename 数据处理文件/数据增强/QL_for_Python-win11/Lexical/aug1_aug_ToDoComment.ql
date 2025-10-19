/**
 * @name Unfinished task marker in comments
 * @description Identifies comments that contain 'TODO' or 'TO DO' markers, which typically
 *              represent incomplete code sections that may accumulate over time in a codebase.
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

from Comment uncompletedTaskComment  // 从所有注释节点中选择变量uncompletedTaskComment
where 
  // 检查注释文本是否包含"TODO"或"TO DO"标记
  exists(string commentText |
    commentText = uncompletedTaskComment.getText() and
    (commentText.matches("%TODO%") or commentText.matches("%TO DO%"))
  )
select uncompletedTaskComment, uncompletedTaskComment.getText()  // 输出包含TODO标记的注释及其文本内容