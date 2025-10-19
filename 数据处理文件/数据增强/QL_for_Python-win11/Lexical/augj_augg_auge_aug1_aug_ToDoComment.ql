/**
 * @name Incomplete task indicators in code annotations
 * @description Detects code annotations that include 'TODO' or 'TO DO' indicators,
 *              signifying unfinished code sections that might build up progressively
 *              and affect code maintenance.
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

from Comment incompleteTaskAnnotation  // Source annotation nodes
where 
  // Extract and analyze annotation text content
  incompleteTaskAnnotation.getText().matches("%TODO%") or 
  incompleteTaskAnnotation.getText().matches("%TO DO%")
select incompleteTaskAnnotation, incompleteTaskAnnotation.getText()  // Output matching annotations and their content