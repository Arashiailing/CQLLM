/**
 * @name File Classification
 * @description Identifies and categorizes files within a codebase snapshot,
 *              distinguishing between generated code and test files.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import the Python module for analyzing Python code
import python
// Import the GeneratedCode filter to detect auto-generated files
import semmle.python.filters.GeneratedCode
// Import the Tests filter to identify test-related files
import semmle.python.filters.Tests

// Define a predicate to determine the classification of a file
predicate classify(File sourceFile, string fileCategory) {
  // First, check if the file is auto-generated
  (
    sourceFile instanceof GeneratedFile
    and
    fileCategory = "generated"
  )
  // Alternatively, check if the file is part of a test scope
  or
  (
    exists(TestScope testScope | testScope.getLocation().getFile() = sourceFile)
    and
    fileCategory = "test"
  )
}

// Select all files along with their classification tags
from File sourceFile, string fileCategory
where classify(sourceFile, fileCategory)
select sourceFile, fileCategory