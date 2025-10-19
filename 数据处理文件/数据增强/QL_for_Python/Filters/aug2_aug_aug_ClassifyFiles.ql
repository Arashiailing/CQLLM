/**
 * @name Source File Type Classification
 * @description Examines source files within a Python codebase to categorize them,
 *              distinguishing between automatically generated files and test files
 *              based on specific identification patterns and location contexts.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import the Python module for Python code analysis capabilities
import python
// Import the GeneratedCode filter to recognize auto-generated source files
import semmle.python.filters.GeneratedCode
// Import the Tests filter to detect files related to testing
import semmle.python.filters.Tests

// Define a predicate to identify auto-generated files
predicate isGeneratedFile(File sourceFile) {
  sourceFile instanceof GeneratedFile
}

// Define a predicate to identify test files
predicate isTestFile(File sourceFile) {
  exists(TestScope testEnvironment | testEnvironment.getLocation().getFile() = sourceFile)
}

// Define a predicate to assign a classification type to each identified file
predicate classifyFile(File sourceFile, string classificationType) {
  // Classify as "generated" for files that match auto-generation patterns
  (isGeneratedFile(sourceFile) and classificationType = "generated")
  // Classify as "test" for files located within test-related directories or contexts
  or
  (isTestFile(sourceFile) and classificationType = "test")
}

// Main query to retrieve all files that match our classification criteria
// along with their assigned classification types
from File sourceFile, string classificationType
where classifyFile(sourceFile, classificationType)
select sourceFile, classificationType