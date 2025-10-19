/**
 * @name File Classification Analysis
 * @description Identifies and categorizes files within a codebase by detecting
 *              auto-generated files and test files based on specific patterns
 *              and location characteristics.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import required modules for Python code analysis and classification
import python
// Import filter for detecting automatically generated code files
import semmle.python.filters.GeneratedCode
// Import filter for identifying test-related files and directories
import semmle.python.filters.Tests

// Predicate that determines the classification category for a given file
// based on whether it's auto-generated or part of test code
predicate determineFileCategory(File fileToAnalyze, string classificationResult) {
  // Classify as "generated" if the file matches auto-generated code patterns
  (fileToAnalyze instanceof GeneratedFile and classificationResult = "generated")
  // Classify as "test" if the file is located within any test-related scope
  or
  (exists(TestScope testContext | testContext.getLocation().getFile() = fileToAnalyze) and classificationResult = "test")
}

// Main query to retrieve all files that match our classification criteria
// along with their assigned category labels
from File fileToAnalyze, string classificationResult
where determineFileCategory(fileToAnalyze, classificationResult)
select fileToAnalyze, classificationResult