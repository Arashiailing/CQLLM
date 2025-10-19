/**
 * @name Source File Type Classification
 * @description Identifies and classifies different types of source files in a codebase,
 *              specifically detecting auto-generated files and test-related files.
 *              The classification is based on file patterns, content markers, and
 *              directory structure analysis. This information is valuable for
 *              security assessments by allowing analysts to focus on relevant code
 *              and exclude automatically generated or test content.
 * @kind file-classifier
 * @id py/file-classifier
 */

// Import Python analysis module for Python-specific code examination
import python
// Import GeneratedCode module to recognize files created by code generators
import semmle.python.filters.GeneratedCode
// Import Tests module to detect test directories and test-related source files
import semmle.python.filters.Tests

// Main query that assigns classification categories to source files
from File sourceFile, string classificationType
where 
  // Classification condition 1: Auto-generated files created by external tools
  sourceFile instanceof GeneratedFile and classificationType = "generated"
  // Classification condition 2: Files located within test directories or test contexts
  or
  exists(TestScope testScope | 
    testScope.getLocation().getFile() = sourceFile and classificationType = "test"
  )
select sourceFile, classificationType