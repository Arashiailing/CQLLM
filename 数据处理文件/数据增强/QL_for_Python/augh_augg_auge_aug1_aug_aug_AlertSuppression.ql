/**
 * @name Alert Suppression
 * @description Detects and handles alert suppressions within Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import modules for alert suppression handling and Python comment processing
private import codeql.util.suppression.AlertSuppression as SuppressionHelper
private import semmle.python.Comment as CommentHandler

// Represents AST nodes with location tracking in Python code
class PythonAstNode instanceof CommentHandler::AstNode {
  /** Provides file path and position information for the node */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Inherit location details from parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Returns string representation of the node */
  string toString() { result = super.toString() }
}

// Represents individual line comments in Python code
class SingleLineComment instanceof CommentHandler::Comment {
  /** Provides file path and position information for the comment */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Inherit location details from parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Retrieves the text content of the comment */
  string getText() { result = super.getContents() }

  /** Returns string representation of the comment */
  string toString() { result = super.toString() }
}

// Establish suppression relationships between AST nodes and comments
import SuppressionHelper::Make<PythonAstNode, SingleLineComment>

/**
 * Handles noqa-style suppression comments compatible with Pylint and Pyflakes
 * These comments should be recognized by the LGTM analyzer
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** Validates the comment follows the noqa format */
  NoqaStyleSuppressor() {
    // Match noqa pattern (case-insensitive, with optional surrounding whitespace)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Returns the annotation identifier for this suppressor */
  override string getAnnotation() { result = "lgtm" }

  /** Defines the code range covered by this suppression comment */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Verify comment is at line start and position matches
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}