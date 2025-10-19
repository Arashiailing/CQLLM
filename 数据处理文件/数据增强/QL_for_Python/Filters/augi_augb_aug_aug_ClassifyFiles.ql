/**
 * @name File Classification Analysis
 * @description Categorizes files as auto-generated or test files using
 *              pattern detection and location-based analysis.
 * @kind file-classifier
 * @id py/file-classifier
 */

import python
import semmle.python.filters.GeneratedCode
import semmle.python.filters.Tests

// Predicate to classify files based on generation status or test context
predicate classifyFile(File targetFile, string category) {
  // Auto-generated file classification
  targetFile instanceof GeneratedFile and category = "generated"
  // Test file classification based on location
  or
  exists(TestScope testContext | 
    testContext.getLocation().getFile() = targetFile
  ) and category = "test"
}

// Main query retrieving classified files with their categories
from File targetFile, string category
where classifyFile(targetFile, category)
select targetFile, category