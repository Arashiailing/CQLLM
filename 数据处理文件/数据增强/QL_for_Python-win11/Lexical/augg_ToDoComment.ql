/**
 * @name TODO comment detection
 * @description Identifies comments containing 'TODO' or 'TO DO' which may indicate
 *              incomplete or pending functionality in the codebase.
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

import python

from Comment todoComment
where 
  todoComment.getText().matches("%TODO%") or 
  todoComment.getText().matches("%TO DO%")
select todoComment, todoComment.getText()