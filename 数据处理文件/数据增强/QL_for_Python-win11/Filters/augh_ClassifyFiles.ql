/**
 * @name Classify source files by type
 * @description Identifies and categorizes Python files as either generated code 
 *              or test code within the analyzed snapshot.
 * @kind file-classifier
 * @id py/file-classifier
 */

import python
import semmle.python.filters.GeneratedCode
import semmle.python.filters.Tests

from File sourceFile, string classificationTag
where 
  // Classify as generated code when file matches generated file criteria
  (sourceFile instanceof GeneratedFile and classificationTag = "generated")
  or
  // Classify as test code when file belongs to any test scope
  (exists(TestScope testScope | testScope.getLocation().getFile() = sourceFile) 
   and classificationTag = "test")
select sourceFile, classificationTag