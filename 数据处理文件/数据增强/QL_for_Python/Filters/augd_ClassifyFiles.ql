/**
 * @name File Classification
 * @description Identifies and categorizes files within a codebase as either
 *              generated code or test code based on predefined criteria.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import the Python module for analyzing Python code
import python
// Import the GeneratedCode filter to identify auto-generated files
import semmle.python.filters.GeneratedCode
// Import the Tests filter to identify test-related files
import semmle.python.filters.Tests

// Define a predicate to classify files with appropriate tags
predicate classify(File sourceFile, string classificationTag) {
  // Check if the file is generated code
  (sourceFile instanceof GeneratedFile and classificationTag = "generated")
  // Check if the file is test code
  or
  (exists(TestScope testScope | testScope.getLocation().getFile() = sourceFile) and classificationTag = "test")
}

// Select all files along with their classification tags
from File sourceFile, string classificationTag
where classify(sourceFile, classificationTag)
select sourceFile, classificationTag