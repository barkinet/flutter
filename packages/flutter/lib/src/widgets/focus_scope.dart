// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'basic.dart';
import 'binding.dart';
import 'focus_manager.dart';
import 'framework.dart';

class _FocusScopeMarker extends InheritedWidget {
  _FocusScopeMarker({
    Key key,
    @required this.node,
    Widget child,
  }) : super(key: key, child: child) {
    assert(node != null);
  }

  final FocusScopeNode node;

  @override
  bool updateShouldNotify(_FocusScopeMarker oldWidget) {
    return node != oldWidget.node;
  }
}

/// Establishes a scope in which widgets can receive focus.
///
/// The focus tree keeps track of which widget is the user's current focus. The
/// focused widget often listens for keyboard events.
///
/// The a focus scope does not itself receive focus but instead helps remember
/// previous focus states. A scope is currently active when its [node] is the
/// first focus of its parent scope. To activate a [FocusScope], either use the
/// [autofocus] property or explicitly make the [node] the first focus in the
/// parent scope:
///
/// ```dart
/// FocusScope.of(context).setFirstFocus(node);
/// ```
///
/// When a [FocusScope] is removed from the tree, the previously active
/// [FocusScope] becomes active again.
///
/// See also:
///
///  * [FocusScopeNode], which is the associated node in the focus tree.
///  * [FocusNode], which is a leaf node in the focus tree that can receive
///    focus.
class FocusScope extends StatefulWidget {
  /// Creates a scope in which widgets can receive focus.
  ///
  /// The [node] argument must not be null.
  FocusScope({
    Key key,
    @required this.node,
    this.autofocus: false,
    this.child,
  }) : super(key: key) {
    assert(node != null);
    assert(autofocus != null);
  }

  /// Controls whether this scope is currently active.
  final FocusScopeNode node;

  /// Whether this scope should attempt to become active when first added to
  /// the tree.
  final bool autofocus;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Returns the [node] of the [FocusScope] that most tightly encloses the
  /// given [BuildContext].
  static FocusScopeNode of(BuildContext context) {
    final _FocusScopeMarker scope = context.inheritFromWidgetOfExactType(_FocusScopeMarker);
    return scope?.node ?? WidgetsBinding.instance.focusManager.rootScope;
  }

  @override
  _FocusScopeState createState() => new _FocusScopeState();
}

class _FocusScopeState extends State<FocusScope> {
  bool _didAutofocus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAutofocus && config.autofocus) {
      FocusScope.of(context).setFirstFocus(config.node);
      _didAutofocus = true;
    }
  }

  @override
  void dispose() {
    config.node.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).reparentScopeIfNeeded(config.node);
    return new Semantics(
      container: true,
      child: new _FocusScopeMarker(
        node: config.node,
        child: config.child,
      ),
    );
  }
}
