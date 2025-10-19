/**
 * @name Unfinished task marker
 * @description This query identifies comments that contain 'TODO' or 'TO DO' indicators,
 *              which typically represent incomplete work that may build up over time.
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

from Comment unmarkedTaskComment  // 从所有注释节点中选择变量unmarkedTaskComment
where 
  // 检查注释文本是否包含"TODO"或"TO DO"标记
  unmarkedTaskComment.getText().matches("%(TODO|TO DO)%")
select unmarkedTaskComment, unmarkedTaskComment.getText()  // 输出包含TODO标记的注释及其文本内容