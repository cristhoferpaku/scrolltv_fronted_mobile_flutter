import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomDirectionalPolicy extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final rectA = a.rect ?? Rect.zero;
        final rectB = b.rect ?? Rect.zero;
        if (rectA.top == rectB.top) {
          return rectA.left.compareTo(rectB.left);
        }
        return rectA.top.compareTo(rectB.top);
      });
    return sorted;
  }
}

class CustomGridTraversalPolicy extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  @override
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final next = _findClosest(currentNode, direction);

    if (next != null) {
      _scrollIntoView(next);
      next.requestFocus();
      return true;
    }

    // Si es horizontal y no hay candidato, bloquea
    if (direction == TraversalDirection.left || direction == TraversalDirection.right) {
      return true; // no hacer nada → no salta de fila
    }

    // Si es vertical y no encontraste, deja que Flutter haga lo suyo
    return super.inDirection(currentNode, direction);
  }

  void _scrollIntoView(FocusNode node) {
    if (node.context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          node.context!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: 0.3, // opcional: 0.5 para centrar
        );
      });
    }
  }

  FocusNode? _findClosest(FocusNode currentNode, TraversalDirection direction) {
    final context = currentNode.context;
    if (context == null) return null;

    final renderBox = context.findRenderObject() as RenderBox;
    final currentPos = renderBox.localToGlobal(Offset.zero);

    final scope = FocusScope.of(context);
    final nodes = scope.traversalDescendants.where((n) => n != currentNode && n.canRequestFocus);

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
          isValid = nodePos.dy < currentPos.dy - 10;
          break;
        case TraversalDirection.down:
          isValid = nodePos.dy > currentPos.dy + 10;
          break;
        case TraversalDirection.left:
          isValid = (nodePos.dx < currentPos.dx - 10) && (nodePos.dy - currentPos.dy).abs() < toleranceY;
          break;
        case TraversalDirection.right:
          isValid = (nodePos.dx > currentPos.dx + 10) && (nodePos.dy - currentPos.dy).abs() < toleranceY;
          break;
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
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final aPos = (a.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        final bPos = (b.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        if ((aPos.dy - bPos.dy).abs() < 10) {
          return aPos.dx.compareTo(bPos.dx);
        }
        return aPos.dy.compareTo(bPos.dy);
      });
    return sorted;
  }
}

//
class CustomGridSection extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final next = _findClosest(currentNode, direction);

    if (next != null) {
      _scrollIntoView(next);
      next.requestFocus();
      return true;
    }

    // Si es horizontal y no hay candidato, bloquea el salto de fila
    if (direction == TraversalDirection.left || direction == TraversalDirection.right) {
      return true;
    }

    // Si es vertical y no hay nada, deja que Flutter maneje el foco
    return super.inDirection(currentNode, direction);
  }

  void _scrollIntoView(FocusNode node) {
    if (node.context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          node.context!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: 0.3,
        );
      });
    }
  }

  FocusNode? _findClosest(FocusNode currentNode, TraversalDirection direction) {
    final context = currentNode.context;
    if (context == null) return null;

    final renderBox = context.findRenderObject() as RenderBox;
    final currentPos = renderBox.localToGlobal(Offset.zero);

    final scope = FocusScope.of(context);
    final nodes = scope.traversalDescendants.where((n) => n != currentNode && n.canRequestFocus);

    FocusNode? closest;
    double minDistance = double.infinity;

    const double toleranceY = 20; // misma fila para izquierda/derecha

    for (final node in nodes) {
      final nodeContext = node.context;
      if (nodeContext == null) continue;

      final nodeBox = nodeContext.findRenderObject() as RenderBox;
      final nodePos = nodeBox.localToGlobal(Offset.zero);

      bool isValid = false;

      switch (direction) {
        case TraversalDirection.up:
          isValid = nodePos.dy < currentPos.dy - 10;
          break;
        case TraversalDirection.down:
          isValid = nodePos.dy > currentPos.dy + 10;
          break;
        case TraversalDirection.left:
          isValid = (nodePos.dx < currentPos.dx - 10) && (nodePos.dy - currentPos.dy).abs() < toleranceY;
          break;
        case TraversalDirection.right:
          isValid = (nodePos.dx > currentPos.dx + 10) && (nodePos.dy - currentPos.dy).abs() < toleranceY;
          break;
      }

      if (!isValid) continue;

      double distance;

      // 🧭 Nuevo comportamiento: arriba/abajo = estrictamente por eje Y
      if (direction == TraversalDirection.up || direction == TraversalDirection.down) {
        distance = (nodePos.dy - currentPos.dy).abs();
      } else {
        // Izquierda/Derecha = distancia euclidiana (mantener)
        distance = (nodePos - currentPos).distance;
      }

      if (distance < minDistance) {
        minDistance = distance;
        closest = node;
      }
    }

    // 🔁 Si hay varios en la misma dirección vertical,
    // el que tenga menor diferencia horizontal será elegido.
    if (closest == null && (direction == TraversalDirection.up || direction == TraversalDirection.down)) {
      // Tomar el primer nodo visible desde la izquierda
      final candidates = nodes.where((n) => n.context != null).toList();
      candidates.sort((a, b) {
        final aPos = (a.context!.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
        final bPos = (b.context!.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
        return aPos.dx.compareTo(bPos.dx); // siempre primero desde la izquierda
      });
      closest = candidates.isNotEmpty ? candidates.first : null;
    }

    return closest;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final aPos = (a.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        final bPos = (b.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        if ((aPos.dy - bPos.dy).abs() < 10) {
          return aPos.dx.compareTo(bPos.dx);
        }
        return aPos.dy.compareTo(bPos.dy);
      });
    return sorted;
  }
}

class CustomGridSectionHorizontal extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final next = _findClosest(currentNode, direction);

    if (next != null) {
      _scrollIntoView(next, direction);
      next.requestFocus();
      return true;
    }

    // Si es horizontal y no hay candidato, bloquea el salto de fila
    if (direction == TraversalDirection.left || direction == TraversalDirection.right) {
      return true;
    }

    // Si es vertical y no hay nada, deja que Flutter maneje el foco
    return super.inDirection(currentNode, direction);
  }

  void _scrollIntoView(FocusNode node, TraversalDirection direction) {
    if (node.context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (direction == TraversalDirection.left || direction == TraversalDirection.right) {
          final renderBox = node.context!.findRenderObject() as RenderBox;
          final scrollable = Scrollable.of(node.context!);
          final scrollPosition = scrollable.position;
          final viewport = scrollPosition.viewportDimension;
          final nodeOffset = renderBox
              .localToGlobal(
                Offset.zero,
                ancestor: scrollable.context.findRenderObject(),
              )
              .dx; // solo eje X
          final scrollOffset = scrollPosition.pixels;

          double targetOffset;
          if (nodeOffset < 0) {
            targetOffset = scrollOffset + nodeOffset;
          } else if (nodeOffset + renderBox.size.width > viewport) {
            targetOffset = scrollOffset + (nodeOffset + renderBox.size.width - viewport);
          } else {
            targetOffset = scrollOffset;
          }

          scrollPosition.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
        // si es vertical, no hace scroll
      });
    }
  }

  FocusNode? _findClosest(FocusNode currentNode, TraversalDirection direction) {
    final context = currentNode.context;
    if (context == null) return null;

    final renderBox = context.findRenderObject() as RenderBox;
    final currentPos = renderBox.localToGlobal(Offset.zero);

    final scope = FocusScope.of(context);
    final nodes = scope.traversalDescendants.where((n) => n != currentNode && n.canRequestFocus);

    FocusNode? closest;
    double minDistance = double.infinity;

    const double toleranceY = 20; // misma fila para izquierda/derecha

    for (final node in nodes) {
      final nodeContext = node.context;
      if (nodeContext == null) continue;

      final nodeBox = nodeContext.findRenderObject() as RenderBox;
      final nodePos = nodeBox.localToGlobal(Offset.zero);

      bool isValid = false;

      switch (direction) {
        case TraversalDirection.up:
          isValid = nodePos.dy < currentPos.dy - 10;
          break;
        case TraversalDirection.down:
          isValid = nodePos.dy > currentPos.dy + 10;
          break;
        case TraversalDirection.left:
          isValid = (nodePos.dx < currentPos.dx - 10) && (nodePos.dy - currentPos.dy).abs() < toleranceY;
          break;
        case TraversalDirection.right:
          isValid = (nodePos.dx > currentPos.dx + 10) && (nodePos.dy - currentPos.dy).abs() < toleranceY;
          break;
      }

      if (!isValid) continue;

      double distance;

      // 🧭 Nuevo comportamiento: arriba/abajo = estrictamente por eje Y
      if (direction == TraversalDirection.up || direction == TraversalDirection.down) {
        distance = (nodePos.dy - currentPos.dy).abs();
      } else {
        // Izquierda/Derecha = distancia euclidiana (mantener)
        distance = (nodePos - currentPos).distance;
      }

      if (distance < minDistance) {
        minDistance = distance;
        closest = node;
      }
    }

    // 🔁 Si hay varios en la misma dirección vertical,
    // el que tenga menor diferencia horizontal será elegido.
    if (closest == null) {
      return null; // no hacer nada, el foco se queda donde está
    }
    return closest;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final aPos = (a.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        final bPos = (b.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        if ((aPos.dy - bPos.dy).abs() < 10) {
          return aPos.dx.compareTo(bPos.dx);
        }
        return aPos.dy.compareTo(bPos.dy);
      });
    return sorted;
  }
}

class CustomGridTraversalPolicyStrictVertical extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final next = _findClosestStrict(currentNode, direction);

    if (next != null) {
      _scrollIntoView(next);
      next.requestFocus();
      return true;
    }

    // Horizontal: bloqueamos si no hay candidato
    if (direction == TraversalDirection.left || direction == TraversalDirection.right) {
      return true;
    }

    // Vertical: dejamos que Flutter haga lo suyo si no encontró
    return super.inDirection(currentNode, direction);
  }

  void _scrollIntoView(FocusNode node) {
    if (node.context != null) {
      final renderObject = node.context!.findRenderObject();
      if (renderObject is RenderBox) {
        final objectOffset = renderObject.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(node.context!).size.height;

        final isAboveScreen = objectOffset.dy < 0;
        final isBelowScreen = objectOffset.dy + renderObject.size.height > screenHeight;

        if (isAboveScreen || isBelowScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Scrollable.ensureVisible(
              node.context!,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: 0.3,
            );
          });
        }
      }
    }
  }

  FocusNode? _findClosestStrict(FocusNode currentNode, TraversalDirection direction) {
    final context = currentNode.context;
    if (context == null) return null;

    final renderBox = context.findRenderObject() as RenderBox;
    final currentPos = renderBox.localToGlobal(Offset.zero);

    final scope = FocusScope.of(context);
    final nodes = scope.traversalDescendants.where((n) => n != currentNode && n.canRequestFocus);

    FocusNode? closest;
    double minDistanceY = double.infinity;

    for (final node in nodes) {
      final nodeContext = node.context;
      if (nodeContext == null) continue;

      final nodeBox = nodeContext.findRenderObject() as RenderBox;
      final nodePos = nodeBox.localToGlobal(Offset.zero);

      bool isValid = false;

      switch (direction) {
        case TraversalDirection.up:
          isValid = nodePos.dy < currentPos.dy - 1; // todo nodo arriba
          break;
        case TraversalDirection.down:
          isValid = nodePos.dy > currentPos.dy + 1; // todo nodo abajo
          break;
        case TraversalDirection.left:
          isValid = nodePos.dx < currentPos.dx - 10 && (nodePos.dy - currentPos.dy).abs() < 20;
          break;
        case TraversalDirection.right:
          isValid = nodePos.dx > currentPos.dx + 10 && (nodePos.dy - currentPos.dy).abs() < 20;
          break;
      }

      if (!isValid) continue;

      // Vertical: solo comparamos distancia y
      final distance = (direction == TraversalDirection.up || direction == TraversalDirection.down) ? (nodePos.dy - currentPos.dy).abs() : (nodePos - currentPos).distance;

      if (distance < minDistanceY) {
        minDistanceY = distance;
        closest = node;
      }
    }

    return closest;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final aPos = (a.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        final bPos = (b.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        if ((aPos.dy - bPos.dy).abs() < 10) {
          return aPos.dx.compareTo(bPos.dx);
        }
        return aPos.dy.compareTo(bPos.dy);
      });
    return sorted;
  }
}

class CustomGridTraversalPolicyStrictVerticalTV extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final next = _findClosestStrict(currentNode, direction);

    if (next != null) {
      _scrollIntoView(next);
      next.requestFocus();
      return true;
    }

    // Horizontal: bloqueamos si no hay candidato
    if (direction == TraversalDirection.left || direction == TraversalDirection.right) {
      return true;
    }

    // Vertical: dejamos que Flutter haga lo suyo si no encontró
    return super.inDirection(currentNode, direction);
  }

  void _scrollIntoView(FocusNode node) {
    if (node.context != null) {
      final renderObject = node.context!.findRenderObject();
      if (renderObject is RenderBox) {
        final objectOffset = renderObject.localToGlobal(Offset.zero);
        final objectHeight = renderObject.size.height;

        final viewport = RenderAbstractViewport.of(renderObject);
        final scrollable = Scrollable.of(node.context!);

        final offset = scrollable.position;
        final revealedOffset = viewport.getOffsetToReveal(renderObject, 0.3).offset;

        if (revealedOffset != offset.pixels) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            offset.animateTo(
              revealedOffset,
              duration: const Duration(milliseconds: 1),
              curve: Curves.easeOut,
            );
          });
        }
      }
    }
  }

  FocusNode? _findClosestStrict(FocusNode currentNode, TraversalDirection direction) {
    final context = currentNode.context;
    if (context == null) return null;

    final renderBox = context.findRenderObject() as RenderBox;
    final currentPos = renderBox.localToGlobal(Offset.zero);

    final scope = FocusScope.of(context);
    final nodes = scope.traversalDescendants.where((n) => n != currentNode && n.canRequestFocus);

    FocusNode? closest;
    double minDistanceY = double.infinity;

    for (final node in nodes) {
      final nodeContext = node.context;
      if (nodeContext == null) continue;

      final nodeBox = nodeContext.findRenderObject() as RenderBox;
      final nodePos = nodeBox.localToGlobal(Offset.zero);

      bool isValid = false;

      switch (direction) {
        case TraversalDirection.up:
          isValid = nodePos.dy < currentPos.dy - 1; // todo nodo arriba
          break;
        case TraversalDirection.down:
          isValid = nodePos.dy > currentPos.dy + 1; // todo nodo abajo
          break;
        case TraversalDirection.left:
          isValid = nodePos.dx < currentPos.dx - 10 && (nodePos.dy - currentPos.dy).abs() < 20;
          break;
        case TraversalDirection.right:
          isValid = nodePos.dx > currentPos.dx + 10 && (nodePos.dy - currentPos.dy).abs() < 20;
          break;
      }

      if (!isValid) continue;

      // Vertical: solo comparamos distancia y
      final distance = (direction == TraversalDirection.up || direction == TraversalDirection.down) ? (nodePos.dy - currentPos.dy).abs() : (nodePos - currentPos).distance;

      if (distance < minDistanceY) {
        minDistanceY = distance;
        closest = node;
      }
    }

    return closest;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final aPos = (a.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        final bPos = (b.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        if ((aPos.dy - bPos.dy).abs() < 10) {
          return aPos.dx.compareTo(bPos.dx);
        }
        return aPos.dy.compareTo(bPos.dy);
      });
    return sorted;
  }
}

class CustomGridTraversalPolicyList extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    if (direction == TraversalDirection.up || direction == TraversalDirection.down) {
      final next = _findClosestStrict(currentNode, direction);

      if (next != null) {
        _scrollIntoView(next);
        next.requestFocus();
        return true; // nodo vertical encontrado y enfocado
      }

      // Si no hay nodo vertical válido, dejamos que Flutter decida
      return false;
    }

    return super.inDirection(currentNode, direction);
  }

  void _scrollIntoView(FocusNode node) {
    if (node.context == null) return;

    final renderObject = node.context!.findRenderObject();
    if (renderObject is! RenderBox) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final scrollable = Scrollable.of(node.context!);

    final offset = scrollable.position;
    final revealedOffset = viewport.getOffsetToReveal(renderObject, 0.3).offset;

    if ((revealedOffset - offset.pixels).abs() > 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        offset.animateTo(
          revealedOffset,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      });
    }
  }

  FocusNode? _findClosestStrict(FocusNode currentNode, TraversalDirection direction) {
    final context = currentNode.context;
    if (context == null) return null;

    final renderBox = context.findRenderObject() as RenderBox;
    final currentPos = renderBox.localToGlobal(Offset.zero);

    final scope = FocusScope.of(context);
    final nodes = scope.traversalDescendants.where((n) => n != currentNode && n.canRequestFocus);

    FocusNode? closest;
    double minDistance = double.infinity;

    const double xTolerance = 40.0;
    const double minVerticalDelta = 1.0;

    for (final node in nodes) {
      final nodeContext = node.context;
      if (nodeContext == null) continue;

      final nodeBox = nodeContext.findRenderObject() as RenderBox;
      final nodePos = nodeBox.localToGlobal(Offset.zero);

      bool isValid = false;
      if (direction == TraversalDirection.up) {
        isValid = nodePos.dy < currentPos.dy - minVerticalDelta && (nodePos.dx - currentPos.dx).abs() < xTolerance;
      } else if (direction == TraversalDirection.down) {
        isValid = nodePos.dy > currentPos.dy + minVerticalDelta && (nodePos.dx - currentPos.dx).abs() < xTolerance;
      }

      if (!isValid) continue;

      final distance = (nodePos.dy - currentPos.dy).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closest = node;
      }
    }

    return closest;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final aPos = (a.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        final bPos = (b.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;

        if ((aPos.dy - bPos.dy).abs() < 10) {
          return aPos.dx.compareTo(bPos.dx);
        }
        return aPos.dy.compareTo(bPos.dy);
      });
    return sorted;
  }
}

class NoVerticalOverflowPolicy extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  final List<FocusNode> nodes;

  NoVerticalOverflowPolicy(this.nodes);

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    // Solo intervenimos en vertical
    if (direction == TraversalDirection.up && currentNode == nodes.first) {
      return true; // bloquea salto hacia arriba en el primer nodo
    }

    if (direction == TraversalDirection.down && currentNode == nodes.last) {
      return true; // bloquea salto hacia abajo en el último nodo
    }

    // Para los demás casos, dejamos que Flutter haga lo suyo
    return super.inDirection(currentNode, direction);
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    // Mantenemos orden por defecto
    return descendants;
  }
}

class VerticalEdgeBlockPolicy extends FocusTraversalPolicy with DirectionalFocusTraversalPolicyMixin {
  final double xTolerance;

  VerticalEdgeBlockPolicy({this.xTolerance = 40.0});

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    if (direction != TraversalDirection.up && direction != TraversalDirection.down) {
      return super.inDirection(currentNode, direction);
    }

    final nodesInColumn = _getNodesInSameColumn(currentNode);
    if (nodesInColumn.isEmpty) return super.inDirection(currentNode, direction);

    // Bloquea solo el primer y último nodo vertical de la columna
    if (direction == TraversalDirection.up && currentNode == nodesInColumn.first) {
      return true; // bloquea salto hacia arriba
    }
    if (direction == TraversalDirection.down && currentNode == nodesInColumn.last) {
      return true; // bloquea salto hacia abajo
    }

    // Para los demás casos, dejamos que Flutter haga su comportamiento por defecto
    return super.inDirection(currentNode, direction);
  }

  /// Obtiene todos los nodos que están en la misma "columna vertical" del nodo actual
  List<FocusNode> _getNodesInSameColumn(FocusNode currentNode) {
    final currentContext = currentNode.context;
    if (currentContext == null) return [];

    final renderBox = currentContext.findRenderObject() as RenderBox;
    final currentDx = renderBox.localToGlobal(Offset.zero).dx;

    final scope = FocusScope.of(currentContext);
    final allNodes = scope.traversalDescendants.where((n) => n != currentNode && n.canRequestFocus);

    final nodesInColumn = allNodes.where((node) {
      final ctx = node.context;
      if (ctx == null) return false;

      final nodeBox = ctx.findRenderObject() as RenderBox;
      final nodeDx = nodeBox.localToGlobal(Offset.zero).dx;

      return (nodeDx - currentDx).abs() < xTolerance;
    }).toList();

    // Incluye el nodo actual y ordena por posición vertical
    nodesInColumn.add(currentNode);
    nodesInColumn.sort((a, b) {
      final aDy = (a.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero).dy ?? 0;
      final bDy = (b.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero).dy ?? 0;
      return aDy.compareTo(bDy);
    });

    return nodesInColumn;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final sorted = descendants.toList()
      ..sort((a, b) {
        final aPos = (a.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
        final bPos = (b.context?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;

        // Orden vertical primero, horizontal después
        if ((aPos.dy - bPos.dy).abs() < 10) {
          return aPos.dx.compareTo(bPos.dx);
        }
        return aPos.dy.compareTo(bPos.dy);
      });
    return sorted;
  }
}
