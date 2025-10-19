/**
 * @name File Type Detection Query
 * @description Analyzes files in a codebase to determine their nature,
 *              distinguishing between auto-generated files and test files
 *              according to specific identification rules.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import Python module for analyzing Python code
import python
// Import GeneratedCode filter to detect auto-generated files
import semmle.python.filters.GeneratedCode
// Import Tests filter to identify test-related files
import semmle.python.filters.Tests

// Define a predicate to assign a category to each file based on its characteristics
predicate assignCategory(File targetFile, string fileCategory) {
  // Assign "generated" category when file exhibits patterns of auto-generated code
  (targetFile instanceof GeneratedFile and fileCategory = "generated")
  // Assign "test" category when file resides within any test-related context
  or
  (exists(TestScope testArea | testArea.getLocation().getFile() = targetFile) and fileCategory = "test")
}

// Query to find all files that match our classification criteria and retrieve their assigned categories
from File targetFile, string fileCategory
where assignCategory(targetFile, fileCategory)
select targetFile, fileCategory