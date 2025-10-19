/**
 * @name Lines of commented-out code in files
 * @description Counts and reports the number of lines containing commented-out code for each file
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

// Import necessary CodeQL modules for Python code analysis and commented code detection
import python
import Lexical.CommentedOutCode

// Define the main query to identify files with commented-out code
from File codeFile, int commentedLinesTotal
where 
    // Calculate the total number of commented lines in each file
    commentedLinesTotal = count(CommentedOutCodeLine commentedCodeLine | 
        // Exclude potential example code from the count
        not commentedCodeLine.maybeExampleCode() and 
        // Ensure the commented line belongs to the current file
        commentedCodeLine.getLocation().getFile() = codeFile)
// Present results showing file paths and their respective counts of commented code lines
select codeFile, commentedLinesTotal 
// Sort the results by the number of commented lines in descending order
order by commentedLinesTotal desc