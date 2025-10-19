/**
 * @name Automated File Categorization
 * @description Analyzes and classifies files in a Python codebase by identifying
 *              automatically generated code and test-related files through pattern
 *              matching and directory structure analysis.
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
predicate determineFileCategory(File sourceFile, string categoryLabel) {
  // Check if the file is auto-generated
  (sourceFile instanceof GeneratedFile and categoryLabel = "generated")
  // Check if the file is part of test code
  or
  (exists(TestScope testScope | testScope.getLocation().getFile() = sourceFile) and categoryLabel = "test")
}

// Main query to retrieve all files that match our classification criteria
// along with their assigned category labels
from File sourceFile, string categoryLabel
where determineFileCategory(sourceFile, categoryLabel)
select sourceFile, categoryLabel