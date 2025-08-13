import 'package:flutter/material.dart';

class CustomGridTraversalPolicy extends FocusTraversalPolicy
    with DirectionalFocusTraversalPolicyMixin {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    super.inDirection(currentNode, direction);
    final next = _findClosest(currentNode, direction);
    if (next != null) {
      next.requestFocus();
      return true;
    }
    return false;
  }

  FocusNode? _findClosest(FocusNode currentNode, TraversalDirection direction) {
    final context = currentNode.context;
    if (context == null) return null;

    final renderBox = context.findRenderObject() as RenderBox;
    final currentPos = renderBox.localToGlobal(Offset.zero);

    final scope = FocusScope.of(context);
    final nodes = scope.traversalDescendants
        .where((n) => n != currentNode && n.canRequestFocus);

    FocusNode? closest;
    double minDistance = double.infinity;

    const double toleranceY = 20; // misma fila para izquierda/derecha

    for (final node in nodes) {
      final nodeContext = node.context;
      if (nodeContext == null) continue;

      final nodeBox = nodeContext.findRenderObject() as RenderBox;
      final nodePos = nodeBox.localToGlobal(Offset.zero);

      bool isValid;
      switch (direction) {
        case TraversalDirection.up:
          isValid = nodePos.dy < currentPos.dy - 10; // solo más arriba
          break;
        case TraversalDirection.down:
          isValid = nodePos.dy > currentPos.dy + 10; // solo más abajo
          break;
        case TraversalDirection.left:
          isValid = (nodePos.dx < currentPos.dx - 10) &&
              (nodePos.dy - currentPos.dy).abs() < toleranceY;
          break;
        case TraversalDirection.right:
          isValid = (nodePos.dx > currentPos.dx + 10) &&
              (nodePos.dy - currentPos.dy).abs() < toleranceY;
          break;
        // default:
        // isValid = false;
      }

      if (!isValid) continue;

      final distance = (nodePos - currentPos).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closest = node;
      }
    }

    return closest;
  }

  @override
  Iterable<FocusNode> sortDescendants(
      Iterable<FocusNode> descendants, FocusNode currentNode) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final aPos = (a.context?.findRenderObject() as RenderBox?)
                ?.localToGlobal(Offset.zero) ??
            Offset.zero;
        final bPos = (b.context?.findRenderObject() as RenderBox?)
                ?.localToGlobal(Offset.zero) ??
            Offset.zero;
        if ((aPos.dy - bPos.dy).abs() < 10) {
          return aPos.dx.compareTo(bPos.dx);
        }
        return aPos.dy.compareTo(bPos.dy);
      });
    return sorted;
  }
}
