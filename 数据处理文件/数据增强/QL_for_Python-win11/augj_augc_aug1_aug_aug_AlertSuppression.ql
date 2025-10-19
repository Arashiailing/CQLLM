/**
 * @name Alert suppression
 * @description Detects and handles alert suppression mechanisms in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL utilities for managing alert suppression functionality
private import codeql.util.suppression.AlertSuppression as AlertSuppressionUtil
// Import Python comment analysis utilities
private import semmle.python.Comment as CommentHandler

// Base class representing Python AST syntax elements
class PythonSyntaxElement instanceof CommentHandler::AstNode {
  /** Extract location details for this syntax element */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Forward location request to parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Generate string representation of the syntax element */
  string toString() { result = super.toString() }
}

// Class representing individual line comments in Python
class PythonSingleLineComment instanceof CommentHandler::Comment {
  /** Extract location details for this comment */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Forward location request to parent implementation
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Retrieve the actual text content of the comment */
  string getText() { result = super.getContents() }

  /** Generate string representation of the comment */
  string toString() { result = super.toString() }
}

// Apply suppression template to establish relationships between syntax elements and comments
import AlertSuppressionUtil::Make<PythonSyntaxElement, PythonSingleLineComment>

/**
 * Represents noqa-style suppression comments compatible with Pylint and Pyflakes
 * These comments are recognized by the LGTM analyzer for alert suppression
 */
class NoqaStyleSuppression extends SuppressionComment instanceof PythonSingleLineComment {
  /** Constructor: verifies comment conforms to noqa specification */
  NoqaStyleSuppression() {
    // Validate comment matches noqa pattern (case-insensitive with optional whitespace)
    PythonSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Return the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Define the scope of code covered by this suppression comment */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Verify comment starts at beginning of line and location matches
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}