/**
 * @name Classify files
 * @description Identifies and categorizes files in a codebase as either
 *              generated code or test code based on predefined criteria.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import necessary modules for Python code analysis
import python
// Import filter for identifying generated code files
import semmle.python.filters.GeneratedCode
// Import filter for identifying test code files
import semmle.python.filters.Tests

// Define a predicate to classify files based on their characteristics
predicate classify(File file, string classification) {
  // Check for generated code classification
  (file instanceof GeneratedFile and classification = "generated")
  or
  // Check for test code classification
  (exists(TestScope testScope | testScope.getLocation().getFile() = file) and classification = "test")
}

// Main query to select and classify files
from File file, string classification
where classify(file, classification)
select file, classification