/**
 * @name Alert Suppression Handling
 * @description Detects and manages alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import utilities for alert suppression handling from CodeQL
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import utilities for processing Python comments
private import semmle.python.Comment as CommentProcessor

// Base class for Python AST syntax nodes
class PySyntaxNode instanceof CommentProcessor::AstNode {
  /** Gets the location information of this syntax node */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Forward location retrieval to the parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Returns a string representation of this syntax node */
  string toString() { result = super.toString() }
}

// Represents a single-line comment in Python source code
class PySingleLineComment instanceof CommentProcessor::Comment {
  /** Gets the location information of this comment */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to the parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Gets the text content of this comment */
  string getText() { result = super.getContents() }

  /** Returns a string representation of this comment */
  string toString() { result = super.toString() }
}

// Apply template to establish suppression relationships between AST nodes and comments
import SuppressionUtils::Make<PySyntaxNode, PySingleLineComment>

/**
 * Represents suppression comments in the noqa format, which is compatible with Pylint and Pyflakes.
 * LGTM analyzer recognizes these comments for suppressing alerts.
 */
class NoqaSuppression extends SuppressionComment instanceof PySingleLineComment {
  /** Constructs a NoqaSuppression by checking the comment format */
  NoqaSuppression() {
    // Verify that the comment text matches the noqa pattern (case-insensitive, with optional surrounding whitespace)
    PySingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Returns the annotation identifier "lgtm" */
  override string getAnnotation() { result = "lgtm" }

  /** Defines the code range that this suppression comment covers */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure the comment is at the beginning of the line and matches the location
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}