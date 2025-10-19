/**
 * @name Alert suppression
 * @description Detects alert suppressions in Python code through comment pattern matching
 * @kind alert-suppression
 * @id py/alert-suppression */

// Core modules for suppression analysis
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * Wrapper class providing AST node location information
 * Inherits base functionality from Python comment module
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Get location coordinates for the AST node
   * @param file - Source file path
   * @param beginLine - Starting line number
   * @param beginCol - Starting column position
   * @param endLine - Ending line number
   * @param endCol - Ending column position
   */
  predicate hasLocationInfo(
    string file, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to parent implementation
    super.getLocation().hasLocationInfo(file, beginLine, beginCol, endLine, endCol)
  }

  /**
   * Generate string representation of the AST node
   * @return Textual representation of the node
   */
  string toString() { result = super.toString() }
}

/**
 * Representation of single-line Python comments
 * Extends base comment functionality from Python comment module
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Get location coordinates for the comment
   * @param file - Source file path
   * @param beginLine - Starting line number
   * @param beginCol - Starting column position
   * @param endLine - Ending line number
   * @param endCol - Ending column position
   */
  predicate hasLocationInfo(
    string file, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to parent implementation
    super.getLocation().hasLocationInfo(file, beginLine, beginCol, endLine, endCol)
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
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents noqa suppression comments compatible with pylint/pyflakes
 * Also recognized by LGTM analysis engine
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructor validating noqa comment format
   * Requires case-insensitive noqa pattern match
   */
  NoqaSuppressionComment() {
    // Validate comment follows noqa specification
    // Pattern allows optional whitespace and trailing content
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Get annotation identifier for this suppression
   * @return "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Define code scope covered by this suppression
   * Covers entire line containing the comment
   * @param file - Source file path
   * @param beginLine - Starting line number (comment line)
   * @param beginCol - Starting column (always 1 for line coverage)
   * @param endLine - Ending line number (comment line)
   * @param endCol - Ending column position
   */
  override predicate covers(
    string file, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Retrieve comment location and enforce line-start coverage
    this.hasLocationInfo(file, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}