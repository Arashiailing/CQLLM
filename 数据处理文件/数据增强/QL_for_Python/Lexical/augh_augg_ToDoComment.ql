/**
 * @name Detection of TODO comments
 * @description Identifies comments containing 'TODO' or 'TO DO' markers, which
 *              typically indicate incomplete code, pending features, or areas
 *              requiring further attention during development.
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

from Comment commentWithTodo
where 
  commentWithTodo.getText().matches("%TODO%") or 
  commentWithTodo.getText().matches("%TO DO%")
select commentWithTodo, commentWithTodo.getText()