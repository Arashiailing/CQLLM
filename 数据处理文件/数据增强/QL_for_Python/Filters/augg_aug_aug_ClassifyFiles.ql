/**
 * @name Python File Classification System
 * @description Systematically categorizes files within a Python codebase by identifying
 *              auto-generated files and test files using predefined classification rules.
 *              This analysis helps in understanding the codebase structure and focusing
 *              security efforts on relevant code sections.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import Python module for analyzing Python code
import python
// Import GeneratedCode filter to detect auto-generated files
import semmle.python.filters.GeneratedCode
// Import Tests filter to identify test-related files
import semmle.python.filters.Tests

// Predicate to identify auto-generated files based on code patterns
predicate isGeneratedFile(File sourceFile) {
  sourceFile instanceof GeneratedFile
}

// Predicate to identify test files based on their location context
predicate isTestFile(File sourceFile) {
  exists(TestScope testContext | testContext.getLocation().getFile() = sourceFile)
}

// Main query to retrieve all files with their assigned classifications
from File sourceFile, string classificationResult
where (
  (isGeneratedFile(sourceFile) and classificationResult = "generated")
  or
  (isTestFile(sourceFile) and classificationResult = "test")
)
select sourceFile, classificationResult