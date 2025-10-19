/**
 * @name Incomplete Task Marker Comment
 * @description Identifies comments containing 'TODO' or 'TO DO' markers. These markers typically
 *              represent unfinished code sections or pending features that require attention.
 *              Accumulation of such markers may indicate technical debt and maintenance challenges.
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

from Comment incompleteComment
where 
  // Check for presence of either 'TODO' or 'TO DO' markers in comment text
  incompleteComment.getText().matches("%(TODO|TO DO)%")
select 
  incompleteComment,  // The comment node containing the marker
  incompleteComment.getText()  // Full text content of the comment