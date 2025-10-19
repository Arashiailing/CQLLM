/**
 * @name Unresolved task marker in comments
 * @description Identifies comments that include 'TODO' or 'TO DO' markers, which often
 *              signify unfinished functionality that can build up in codebases.
 *              Addressing these markers is important for enhancing code maintainability.
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

from Comment commentElement, string commentText  // Select comment elements and their textual content
where 
  commentText = commentElement.getText()  // Extract text from comment element
  and
  // Check for presence of unresolved task markers
  (commentText.matches("%TODO%") or commentText.matches("%TO DO%"))
select commentElement, commentText  // Output the comment element and its full text content