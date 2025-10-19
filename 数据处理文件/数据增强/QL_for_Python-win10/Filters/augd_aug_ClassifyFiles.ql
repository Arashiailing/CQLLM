/**
 * @name File Classification
 * @description Analyzes and categorizes files in a codebase, differentiating between
 *              auto-generated code and test files to provide a clear overview of the code structure.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import the Python module for analyzing Python code
import python
// Import the GeneratedCode filter to detect auto-generated files
import semmle.python.filters.GeneratedCode
// Import the Tests filter to identify test-related files
import semmle.python.filters.Tests

// Define a predicate to determine the category of a file
predicate determineFileCategory(File codeFile, string classificationTag) {
  // Check if the file is auto-generated
  codeFile instanceof GeneratedFile
  and
  classificationTag = "generated"
  or
  // Check if the file is part of a test scope
  exists(TestScope testScope | testScope.getLocation().getFile() = codeFile)
  and
  classificationTag = "test"
}

// Select all files along with their classification tags
from File codeFile, string classificationTag
where determineFileCategory(codeFile, classificationTag)
select codeFile, classificationTag