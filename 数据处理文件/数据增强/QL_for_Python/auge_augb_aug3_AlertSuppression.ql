/**
 * @name Alert suppression
 * @description Identifies alert suppressions in Python code through comment analysis
 * @kind alert-suppression
 * @id py/alert-suppression */

// Core modules for alert suppression handling
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * AST node wrapper providing location information
 * Inherits from Python comment module's AST node base class
 */
class AstNode instanceof PythonComment::AstNode {
  /**
   * Retrieves detailed location coordinates for the node
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startCol - Beginning column number
   * @param endLine - Ending line number
   * @param endCol - Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Returns string representation of the AST node */
  string toString() { result = super.toString() }
}

/**
 * Single-line comment wrapper for Python code
 * Extends base Comment class from Python comment module
 */
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Retrieves detailed location coordinates for the comment
   * @param filePath - Source file path
   * @param startLine - Beginning line number
   * @param startCol - Beginning column number
   * @param endLine - Ending line number
   * @param endCol - Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Returns the actual text content of the comment */
  string getText() { result = super.getContents() }

  /** Returns string representation of the comment */
  string toString() { result = super.toString() }
}

// Establish suppression relationship using AlertSuppression template
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents noqa suppression comments recognized by pylint, pyflakes and LGTM
 * Handles case-insensitive noqa patterns with optional trailing content
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Validates noqa comment format during construction
   * Matches pattern: optional whitespace, "noqa" (case-insensitive), 
   * optional non-colon content
   */
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Returns "lgtm" as the standardized annotation identifier */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range suppressed by this comment
   * Covers the entire line where the comment appears
   * @param filePath - Source file path
   * @param startLine - Starting line number (comment line)
   * @param startCol - Starting column (always 1 for line coverage)
   * @param endLine - Ending line number (comment line)
   * @param endCol - Ending column number
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}