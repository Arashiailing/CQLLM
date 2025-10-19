/**
 * @name Unfinished task marker in comments
 * @description Detects comments containing 'TODO' or 'TO DO' markers that indicate
 *              incomplete code segments, potentially leading to technical debt accumulation.
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

from Comment comment  // Select comment nodes from the codebase
where 
  // Check for presence of task markers in comment text
  exists(string taskMarker | 
    taskMarker = "TODO" or taskMarker = "TO DO" and
    comment.getText().matches("%" + taskMarker + "%")
  )
select comment, comment.getText()  // Output matching comments and their text content