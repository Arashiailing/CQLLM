/**
 * @name 'To Do' comment detection
 * @description Detects comments that contain 'TODO' or 'TO DO' markers,
 *              which typically indicate incomplete functionality or pending work.
 *              These markers are useful for tracking development tasks but should
 *              be resolved before production release.
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

import python  // Import Python language module for code analysis

from Comment commentWithTodoMarker  // Select all comment nodes for analysis
where 
  // Extract comment text once for efficiency and check for TODO markers
  exists(string commentText | 
    commentText = commentWithTodoMarker.getText() and
    // Match both 'TODO' and 'TO DO' patterns in the comment text
    (commentText.matches("%TODO%") or commentText.matches("%TO DO%"))
  )
select 
  commentWithTodoMarker,  // Select the comment node containing TODO markers
  commentWithTodoMarker.getText()  // Display the actual comment text for review