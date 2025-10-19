/**
 * @name Lines of commented-out code in files
 * @description Identifies and quantifies lines of commented-out code within Python files,
 *              excluding lines that are likely examples or documentation. This metric
 *              helps identify files that may contain excessive legacy code or temporary
 *              debugging code that should be removed. Results are visualized as a treemap
 *              to highlight files with the highest concentration of commented code.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @tags maintainability
 * @id py/lines-of-commented-out-code-in-files
 */

import python
import Lexical.CommentedOutCode

from File sourceFile, int commentedLinesCount
where 
    // Calculate the total number of commented-out code lines for each file
    // Exclude lines that are likely example code or documentation
    commentedLinesCount = count(CommentedOutCodeLine commentedLine | 
        // Ensure the commented line is not an example
        not commentedLine.maybeExampleCode() and 
        // Ensure the commented line belongs to the current file being analyzed
        commentedLine.getLocation().getFile() = sourceFile)
// Present results sorted by the number of commented lines in descending order
// Files with more commented code will appear first in the results
select sourceFile, commentedLinesCount order by commentedLinesCount desc