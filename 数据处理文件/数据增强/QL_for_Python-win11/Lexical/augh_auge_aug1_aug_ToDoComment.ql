/**
 * @name Unfinished task marker in comments
 * @description Identifies comments containing 'TODO' or 'TO DO' markers, which signify
 *              incomplete code that may accumulate and contribute to technical debt.
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

from Comment commentNode  // Select comment nodes from the codebase
where 
  // Check for presence of task markers in comment text
  exists(string marker | 
    marker = "TODO" or marker = "TO DO" and
    commentNode.getText().matches("%" + marker + "%")
  )
select commentNode, commentNode.getText()  // Output matching comments and their text content