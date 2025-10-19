/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import required modules for alert suppression functionality
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * Wrapper class for AST nodes to provide location information
 * Extends the base AST node from Python comment module
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Get detailed location information for the node
   * @param filepath - The file path containing the node
   * @param startline - Starting line number
   * @param startcolumn - Starting column number
   * @param endline - Ending line number
   * @param endcolumn - Ending column number
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Delegate to parent class to retrieve location information
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  /**
   * Get string representation of the AST node
   * @return String representation of the node
   */
  string toString() { result = super.toString() }
}

/**
 * Wrapper class for single-line comments in Python code
 * Extends the base Comment class from Python comment module
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Get detailed location information for the comment
   * @param filepath - The file path containing the comment
   * @param startline - Starting line number
   * @param startcolumn - Starting column number
   * @param endline - Ending line number
   * @param endcolumn - Ending column number
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Delegate to parent class to retrieve location information
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  /**
   * Get the text content of the comment
   * @return The actual comment text
   */
  string getText() { result = super.getContents() }

  /**
   * Get string representation of the comment
   * @return String representation of the comment
   */
  string toString() { result = super.toString() }
}

// Establish suppression relationship between nodes and comments using AlertSuppression template
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment that is recognized by both pylint and pyflakes
 * This comment type is also respected by LGTM analysis
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructor that validates the noqa comment format
   * The comment must match the noqa pattern (case-insensitive)
   */
  NoqaSuppressionComment() {
    // Verify that the comment text follows the noqa format pattern
    // Pattern allows optional whitespace and optional content after noqa
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Get the annotation identifier for this suppression comment
   * @return The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Define the code range covered by this suppression comment
   * The comment covers the entire line where it appears
   * @param filepath - The file path containing the comment
   * @param startline - Starting line number (same as comment line)
   * @param startcolumn - Starting column number (always 1 for line coverage)
   * @param endline - Ending line number (same as comment line)
   * @param endcolumn - Ending column number
   */
  override predicate covers(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Get comment location and ensure it starts at the beginning of the line
    this.hasLocationInfo(filepath, startline, _, endline, endcolumn) and
    startcolumn = 1
  }
}