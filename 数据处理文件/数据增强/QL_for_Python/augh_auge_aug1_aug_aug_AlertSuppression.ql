/**
 * @name Alert suppression
 * @description Detects and processes alert suppression comments in Python source code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import required modules for suppression handling and Python comment analysis
private import codeql.util.suppression.AlertSuppression as SuppressionHelper
private import semmle.python.Comment as CommentHandler

// Represents AST nodes with location tracking capabilities
class PythonAstNode instanceof CommentHandler::AstNode {
  /** Retrieves location details including file path and position coordinates */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Provides string representation of the AST node */
  string toString() { result = super.toString() }
}

// Represents individual line comments in Python source files
class SingleLineComment instanceof CommentHandler::Comment {
  /** Retrieves location details for the comment */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Extracts the raw text content of the comment */
  string getText() { result = super.getContents() }

  /** Provides string representation of the comment */
  string toString() { result = super.toString() }
}

// Apply suppression template to establish node-comment relationships
import SuppressionHelper::Make<PythonAstNode, SingleLineComment>

/**
 * Handles noqa-style suppression comments compatible with Pylint/Pyflakes
 * These comments should be recognized by LGTM analyzers
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** Validates comment format matches noqa pattern */
  NoqaStyleSuppressor() {
    // Check for case-insensitive noqa pattern with optional trailing content
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Returns the annotation identifier for this suppressor */
  override string getAnnotation() { result = "lgtm" }

  /** Defines the code range covered by this suppression comment */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Ensure comment starts at beginning of line and matches position
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}