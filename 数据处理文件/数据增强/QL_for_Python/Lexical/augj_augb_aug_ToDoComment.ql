/**
 * @name Unfinished task marker
 * @description Detects comments containing 'TODO' or 'TO DO' indicators,
 *              which typically represent incomplete work that may accumulate over time.
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

from Comment todoComment  // Select all comment nodes as variable todoComment
where 
  // Verify if the comment text contains either 'TODO' or 'TO DO' markers
  todoComment.getText().matches("%(TODO|TO DO)%")
select todoComment, todoComment.getText()  // Output the comment containing TODO markers and its text content