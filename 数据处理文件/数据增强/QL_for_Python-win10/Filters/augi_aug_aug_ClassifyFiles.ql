/**
 * @name Source File Classification Analysis
 * @description Systematically categorizes files in a codebase by differentiating
 *              between auto-generated code artifacts and test-related files
 *              based on predefined identification patterns.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import Python module for analyzing Python code
import python
// Import GeneratedCode filter to detect auto-generated files
import semmle.python.filters.GeneratedCode
// Import Tests filter to identify test-related files
import semmle.python.filters.Tests

// Define a predicate to assign a classification type to each file based on its characteristics
predicate assignClassification(File sourceFile, string classificationType) {
  // Assign "generated" classification when file exhibits patterns of auto-generated code
  (sourceFile instanceof GeneratedFile and classificationType = "generated")
  // Assign "test" classification when file resides within any test-related context
  or
  (exists(TestScope testContext | testContext.getLocation().getFile() = sourceFile) and classificationType = "test")
}

// Query to retrieve all files matching our classification criteria along with their assigned types
from File sourceFile, string classificationType
where assignClassification(sourceFile, classificationType)
select sourceFile, classificationType