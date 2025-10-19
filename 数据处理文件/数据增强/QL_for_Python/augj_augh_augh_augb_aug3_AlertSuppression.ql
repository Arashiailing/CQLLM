/**
 * @name Alert suppression
 * @description Identifies alert suppressions in Python code via comment pattern analysis
 * @kind alert-suppression
 * @id py/alert-suppression */

// Core modules for suppression analysis
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * AST node wrapper providing location information
 * Inherits base functionality from Python comment module
 */
class AstNodeWrapper instanceof PythonComment::AstNode {
  /**
   * Retrieve location coordinates for the AST node
   * @param filePath - Source file path
   * @param startLine - Starting line number
   * @param startCol - Starting column position
   * @param stopLine - Ending line number
   * @param stopCol - Ending column position
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int stopLine, int stopCol
  ) {
    // Delegate location retrieval to parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, stopLine, stopCol)
  }

  /**
   * Generate string representation of the AST node
   * @return Textual representation of the node
   */
  string toString() { result = super.toString() }
}

/**
 * Single-line Python comment representation
 * Extends base comment functionality from Python comment module
 */
class SingleLineCommentImpl instanceof PythonComment::Comment {
  /**
   * Retrieve location coordinates for the comment
   * @param filePath - Source file path
   * @param startLine - Starting line number
   * @param startCol - Starting column position
   * @param stopLine - Ending line number
   * @param stopCol - Ending column position
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int stopLine, int stopCol
  ) {
    // Delegate location retrieval to parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, stopLine, stopCol)
  }

  /**
   * Extract the raw text content of the comment
   * @return Unprocessed comment text
   */
  string getText() { result = super.getContents() }

  /**
   * Generate string representation of the comment
   * @return Textual representation of the comment
   */
  string toString() { result = super.toString() }
}

// Configure suppression mapping between AST nodes and comments
import AlertSuppression::Make<AstNodeWrapper, SingleLineCommentImpl>

/**
 * Represents noqa suppression comments compatible with pylint/pyflakes
 * Also recognized by LGTM analysis engine
 */
class NoqaSuppressionCommentImpl extends SuppressionComment instanceof SingleLineCommentImpl {
  /**
   * Constructor validating noqa comment format
   * Requires case-insensitive noqa pattern match
   */
  NoqaSuppressionCommentImpl() {
    // Validate comment follows noqa specification
    // Pattern allows optional whitespace and trailing content
    this.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Get annotation identifier for this suppression
   * @return "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Define code scope covered by this suppression
   * Covers entire line containing the comment
   * @param filePath - Source file path
   * @param startLine - Starting line number (comment line)
   * @param startCol - Starting column (always 1 for line coverage)
   * @param stopLine - Ending line number (comment line)
   * @param stopCol - Ending column position
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int stopLine, int stopCol
  ) {
    // Retrieve comment location and enforce line-start coverage
    this.hasLocationInfo(filePath, startLine, _, stopLine, stopCol) and
    startCol = 1
  }
}