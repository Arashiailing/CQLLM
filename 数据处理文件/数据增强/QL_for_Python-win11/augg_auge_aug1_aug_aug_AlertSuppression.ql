/**
 * @name Alert Suppression
 * @description Detects and handles alert suppressions within Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import modules for handling alert suppression and Python comments
private import codeql.util.suppression.AlertSuppression as SuppressionHelper
private import semmle.python.Comment as CommentHandler

// Represents AST nodes in Python code with location tracking
class PythonAstNode instanceof CommentHandler::AstNode {
  /** Retrieves file path and position information for this node */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate to parent class for location details
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Provides string representation of the node */
  string toString() { result = super.toString() }
}

// Represents individual line comments in Python code
class SingleLineComment instanceof CommentHandler::Comment {
  /** Retrieves file path and position information for this comment */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate to parent class for location details
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Extracts the text content of the comment */
  string getText() { result = super.getContents() }

  /** Provides string representation of the comment */
  string toString() { result = super.toString() }
}

// Apply suppression template to establish relationships between AST nodes and comments
import SuppressionHelper::Make<PythonAstNode, SingleLineComment>

/**
 * Handles noqa-style suppression comments compatible with Pylint and Pyflakes
 * These comments should be recognized by the LGTM analyzer
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** Validates that the comment follows the noqa format */
  NoqaStyleSuppressor() {
    // Check for noqa pattern (case-insensitive, with optional surrounding whitespace)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Returns the annotation identifier for this suppressor */
  override string getAnnotation() { result = "lgtm" }

  /** Defines the code range covered by this suppression comment */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure comment is at the beginning of a line and position matches
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}