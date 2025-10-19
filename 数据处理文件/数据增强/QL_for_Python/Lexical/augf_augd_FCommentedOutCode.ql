/**
 * @name Lines of commented-out code in files
 * @description Computes the total count of lines containing commented-out code for each Python source file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary CodeQL modules for Python analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Select Python source files and their corresponding counts of commented-out code lines
from File pyFile, int commentedCodeLineCount
where 
  // Calculate the total number of commented-out code lines in each file
  commentedCodeLineCount = count(CommentedOutCodeLine commentedOutLine | 
    // Filter for commented lines that belong to the current Python file
    commentedOutLine.getLocation().getFile() = pyFile and
    // Exclude lines that are potentially example code
    not commentedOutLine.maybeExampleCode()
  )
// Output the Python file and its commented code line count, ordered by count in descending order
select pyFile, commentedCodeLineCount order by commentedCodeLineCount desc