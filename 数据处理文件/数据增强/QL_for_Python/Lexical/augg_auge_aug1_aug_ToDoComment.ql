/**
 * @name Unfinished task marker in comments
 * @description Identifies code comments containing 'TODO' or 'TO DO' markers,
 *              indicating incomplete code segments that may accumulate over time
 *              and impact maintainability.
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

import python  // Python language library for code analysis

from Comment unfinishedTaskComment  // Source comment nodes
where 
  // Extract and analyze comment text content
  exists(string commentContent | 
    commentContent = unfinishedTaskComment.getText() and
    // Match common unfinished task patterns
    (commentContent.matches("%TODO%") or commentContent.matches("%TO DO%"))
  )
select unfinishedTaskComment, unfinishedTaskComment.getText()  // Output matching comments and their content