/**
 * @name Unresolved task marker in comments
 * @description Identifies comments containing 'TODO' or 'TO DO' markers, which typically
 *              represent incomplete features that may accumulate in codebases over time.
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

import python  // Import Python language library for analyzing Python source code

from Comment taskMarkerComment, string commentText  // Select comment nodes and their text
where 
  // Extract the comment text and check for task markers
  commentText = taskMarkerComment.getText() and
  (commentText.matches("%TODO%") or commentText.matches("%TO DO%"))
select taskMarkerComment, commentText  // Output the comment node and its text content