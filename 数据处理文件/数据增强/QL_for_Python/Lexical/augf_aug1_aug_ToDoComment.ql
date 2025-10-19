/**
 * @name Unfinished task marker in comments
 * @description Detects code comments containing 'TODO' or 'TO DO' markers, which
 *              indicate incomplete code sections that might accumulate over time
 *              in a codebase, potentially affecting maintainability.
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

from Comment taskMarkerComment
where 
  exists(string textContent |
    textContent = taskMarkerComment.getText() and
    (textContent.matches("%TODO%") or textContent.matches("%TO DO%"))
  )
select taskMarkerComment, taskMarkerComment.getText()