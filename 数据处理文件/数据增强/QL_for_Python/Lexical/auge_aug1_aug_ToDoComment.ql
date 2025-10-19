/**
 * @name Unfinished task marker in comments
 * @description Detects comments containing 'TODO' or 'TO DO' markers, which indicate
 *              unfinished code segments that might pile up in the codebase over time.
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

import python  // Import Python language library for analyzing Python code

from Comment todoComment, string text  // Select comment nodes and their text content
where 
  // Associate comment text with the comment
  text = todoComment.getText() and
  // Check for TODO markers in the text
  (text.matches("%TODO%") or text.matches("%TO DO%"))
select todoComment, todoComment.getText()  // Output comments with TODO markers and their text content