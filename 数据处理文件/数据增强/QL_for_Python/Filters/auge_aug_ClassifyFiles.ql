/**
 * @name Codebase File Categorization
 * @description Analyzes and labels files in a project repository,
 *              differentiating between auto-generated code and test-related files.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import necessary Python analysis module
import python
// Import the GeneratedCode filter for identifying automatically generated files
import semmle.python.filters.GeneratedCode
// Import the Tests filter for detecting test-related files
import semmle.python.filters.Tests

// Define a predicate that assigns a category to each file based on its characteristics
predicate classify(File targetFile, string categoryLabel) {
  // Check if the file is marked as auto-generated
  targetFile instanceof GeneratedFile and categoryLabel = "generated"
  or
  // Or check if the file is associated with any test scope
  exists(TestScope testScope | 
    testScope.getLocation().getFile() = targetFile and 
    categoryLabel = "test"
  )
}

// Query to retrieve files and their assigned categories
from File targetFile, string categoryLabel
where classify(targetFile, categoryLabel)
select targetFile, categoryLabel