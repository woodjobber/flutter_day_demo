part of 'dismissible_page.dart';

class _DismissiblePageScrollBehavior extends ScrollBehavior {
  const _DismissiblePageScrollBehavior();

  @override
  Widget buildOverscrollIndicator(_, Widget child, __) => child;
}

mixin _DismissiblePageMixin {
  late final AnimationController _moveController;
  int _activePointerCount = 0;

  // ignore: prefer_final_fields
  bool _dragUnderway = false;
  Axis? _axis;
  bool get _isActive => _dragUnderway || _moveController.isAnimating;
}

class _DismissiblePageListener extends StatelessWidget {
  const _DismissiblePageListener({
    required this.parentState,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.direction,
    required this.child,
    this.onPointerDown,
    required this.onNotification,
    Key? key,
  }) : super(key: key);

  final _DismissiblePageMixin parentState;
  final ValueChanged<Offset> onStart;
  final ValueChanged<DragEndDetails> onEnd;
  final ValueChanged<DragUpdateDetails> onUpdate;
  final ValueChanged<PointerDownEvent>? onPointerDown;
  final DismissiblePageDismissDirection direction;
  final ValueChanged<Axis> onNotification;
  final Widget child;

  bool get _dragUnderway => parentState._dragUnderway;
  Axis? get _axis => parentState._axis;
  void _startOrUpdateDrag(DragUpdateDetails? details) {
    if (details == null) return;
    if (_dragUnderway) {
      onUpdate(details);
    } else {
      onStart(details.globalPosition);
    }
  }

  void _updateDrag(DragUpdateDetails? details) {
    if (details != null && details.primaryDelta != null) {
      if (_dragUnderway) {
        onUpdate(details);
      }
    }
  }

  bool _isSameDirections(Axis axis) {
    switch (direction) {
      case DismissiblePageDismissDirection.vertical:
      case DismissiblePageDismissDirection.up:
      case DismissiblePageDismissDirection.down:
        return axis == Axis.vertical;
      case DismissiblePageDismissDirection.horizontal:
      case DismissiblePageDismissDirection.endToStart:
      case DismissiblePageDismissDirection.startToEnd:
        return axis == Axis.horizontal;
      case DismissiblePageDismissDirection.none:
        return false;
      case DismissiblePageDismissDirection.multi:
        return true;
    }
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    onNotification.call(scrollInfo.metrics.axis);
    if (_isSameDirections(scrollInfo.metrics.axis)) {
      if (scrollInfo is OverscrollNotification) {
        _startOrUpdateDrag(scrollInfo.dragDetails);
        return false;
      }

      if (scrollInfo is ScrollUpdateNotification) {
        if (scrollInfo.metrics.outOfRange) {
          _startOrUpdateDrag(scrollInfo.dragDetails);
        } else {
          _updateDrag(scrollInfo.dragDetails);
        }
        return false;
      }
    }

    return false;
  }

  void _onPointerDown(PointerDownEvent event) {
    parentState._activePointerCount++;
    onPointerDown?.call(event);
  }

  void _onPointerUp(_) {
    parentState._activePointerCount--;
    if (_dragUnderway && parentState._activePointerCount == 0) {
      onEnd(DragEndDetails());
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_dragUnderway) {
      return;
    }
    if (_axis != null && (_isSameDirections(_axis!))) {
      var details = DragUpdateDetails(globalPosition: event.position);
      _startOrUpdateDrag(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerCancel: _onPointerUp,
      onPointerUp: _onPointerUp,
      onPointerMove: _onPointerMove,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: child,
      ),
    );
  }
}
