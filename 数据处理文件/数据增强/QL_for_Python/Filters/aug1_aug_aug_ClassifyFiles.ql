/**
 * @name Codebase File Classification Analysis
 * @description Identifies and categorizes files within a codebase by detecting
 *              auto-generated files and test files using predefined patterns
 *              and contextual analysis.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import Python module for analyzing Python code
import python
// Import GeneratedCode filter to detect auto-generated files
import semmle.python.filters.GeneratedCode
// Import Tests filter to identify test-related files
import semmle.python.filters.Tests

// Main query to classify files based on their characteristics and context
from File sourceFile, string classificationType
where 
  // Classify as "generated" when file matches auto-generated patterns
  (sourceFile instanceof GeneratedFile and classificationType = "generated")
  // Classify as "test" when file is located within any test-related context
  or
  (exists(TestScope testContext | testContext.getLocation().getFile() = sourceFile) and classificationType = "test")
select sourceFile, classificationType