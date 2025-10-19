/**
 * @name 'To Do' comment detection
 * @description Detects comments containing 'TODO' or 'TO DO' markers that indicate
 *              incomplete features or pending tasks in the code.
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

import python  // Python language library for code analysis

from Comment pendingTaskComment  // Select all comment nodes
where 
  // Check if comment contains task markers
  pendingTaskComment.getText().matches("%TODO%") or 
  pendingTaskComment.getText().matches("%TO DO%")
select 
  pendingTaskComment,  // The matching comment node
  pendingTaskComment.getText()  // and its text content