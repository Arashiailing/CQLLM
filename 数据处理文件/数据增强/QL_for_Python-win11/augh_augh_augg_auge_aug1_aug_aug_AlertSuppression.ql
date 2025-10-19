/**
 * @name Alert Suppression
 * @description Identifies and processes alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import necessary modules for suppression handling and Python comment analysis
private import codeql.util.suppression.AlertSuppression as SuppressionHelper
private import semmle.python.Comment as CommentHandler

// Represents Python AST nodes equipped with location tracking capabilities
class PythonNodeWithLocation instanceof CommentHandler::AstNode {
  /** Provides file path and position details for the AST node */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location information retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Returns a string representation of the AST node */
  string toString() { result = super.toString() }
}

// Represents individual line-based comments within Python source files
class LineComment instanceof CommentHandler::Comment {
  /** Provides file path and position details for the comment */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location information retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Retrieves the textual content of the comment */
  string getText() { result = super.getContents() }

  /** Returns a string representation of the comment */
  string toString() { result = super.toString() }
}

// Establish the relationship between AST nodes and suppression comments
import SuppressionHelper::Make<PythonNodeWithLocation, LineComment>

/**
 * Processes noqa-style suppression comments that are compatible with 
 * Pylint and Pyflakes tools. These comments should be recognized by LGTM.
 */
class NoqaSuppression extends SuppressionComment instanceof LineComment {
  /** Ensures the comment follows the noqa suppression format */
  NoqaSuppression() {
    // Match the noqa pattern (case-insensitive, with optional surrounding whitespace)
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Returns the annotation identifier for this suppression mechanism */
  override string getAnnotation() { result = "lgtm" }

  /** Specifies the code range affected by this suppression comment */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure the comment is at the beginning of a line and position matches
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}