/**
 * @name Unfinished task marker in comments
 * @description Identifies code comments containing 'TODO' or 'TO DO' markers that indicate
 *              incomplete code sections. These markers can accumulate in a codebase over time,
 *              potentially creating technical debt and affecting maintainability.
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
  exists(string commentText |
    commentText = todoComment.getText() and
    (
      commentText.matches("%TODO%") or 
      commentText.matches("%TO DO%")
    )
  )
select todoComment, todoComment.getText()