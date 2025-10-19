/**
 * @name File Classification
 * @description Categorizes files in a codebase snapshot as either 
 *              auto-generated code or test-related files.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import core Python analysis module
import python
// Import filter for detecting auto-generated files
import semmle.python.filters.GeneratedCode
// Import filter for identifying test files
import semmle.python.filters.Tests

// Select files with their classification tags
from File targetFile, string classificationTag
where 
  // Check if file is auto-generated
  (targetFile instanceof GeneratedFile and classificationTag = "generated")
  or
  // Check if file is part of test scope
  (exists(TestScope testScope | testScope.getLocation().getFile() = targetFile) 
   and classificationTag = "test")
select targetFile, classificationTag