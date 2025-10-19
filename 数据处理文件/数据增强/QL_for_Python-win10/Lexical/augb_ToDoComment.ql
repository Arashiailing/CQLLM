/**
 * @name 'To Do' comment
 * @description Identifies code comments containing 'TODO' or 'TO DO', which typically indicate
 *              incomplete features or temporary solutions that should be addressed.
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
where todoComment.getText().matches("%(TODO|TO DO)%")  // 过滤条件：匹配包含"TODO"或"TO DO"的注释文本
select todoComment, todoComment.getText()  // 选择符合条件的注释节点及其文本内容