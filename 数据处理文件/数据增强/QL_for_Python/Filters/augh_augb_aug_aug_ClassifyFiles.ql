/**
 * @name File Classification Analysis
 * @description Categorizes files by detecting auto-generated code and test files
 *              using pattern matching and location-based analysis
 * @kind file-classifier
 * @id py/file-classifier
 */

import python
import semmle.python.filters.GeneratedCode
import semmle.python.filters.Tests

// Determines classification category for a target file based on:
// - Auto-generated code patterns
// - Test directory structure conventions
predicate determineFileCategory(File targetFile, string categoryLabel) {
  // Auto-generated file classification
  (targetFile instanceof GeneratedFile and categoryLabel = "generated")
  or
  // Test file classification through location analysis
  (exists(TestScope testLocation | 
    testLocation.getLocation().getFile() = targetFile
  ) and categoryLabel = "test")
}

// Retrieves all classified files with their assigned category labels
from File targetFile, string categoryLabel
where determineFileCategory(targetFile, categoryLabel)
select targetFile, categoryLabel