/**
 * @name Unresolved task marker in comments
 * @description Detects comments containing 'TODO' or 'TO DO' markers, which typically
 *              indicate incomplete features that may accumulate in codebases over time.
 *              These markers should be resolved to improve code maintainability.
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

from Comment commentNode, string commentContent  // Select comment nodes and their textual content
where 
  // Extract comment text and check for unresolved task markers
  commentContent = commentNode.getText() and
  (commentContent.matches("%TODO%") or commentContent.matches("%TO DO%"))
select commentNode, commentContent  // Output the comment node and its full text content