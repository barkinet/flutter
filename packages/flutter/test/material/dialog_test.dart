// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dialog is scrollable', (WidgetTester tester) async {
    bool didPressOk = false;

    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Builder(
            builder: (BuildContext context) {
              return new Center(
                child: new RaisedButton(
                  child: new Text('X'),
                  onPressed: () {
                    showDialog<Null>(
                      context: context,
                      child: new AlertDialog(
                        content: new Container(
                          height: 5000.0,
                          width: 300.0,
                          decoration: new BoxDecoration(
                            backgroundColor: Colors.green[500]
                          )
                        ),
                        actions: <Widget>[
                          new FlatButton(
                            onPressed: () {
                              didPressOk = true;
                            },
                            child: new Text('OK')
                          )
                        ]
                      )
                    );
                  }
                )
              );
            }
          )
        )
      )
    );

    await tester.tap(find.text('X'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1));

    expect(didPressOk, false);
    await tester.tap(find.text('OK'));
    expect(didPressOk, true);
  });

  testWidgets('Dialog background color', (WidgetTester tester) async {

    await tester.pumpWidget(
      new MaterialApp(
        theme: new ThemeData(brightness: Brightness.dark),
        home: new Material(
          child: new Builder(
            builder: (BuildContext context) {
              return new Center(
                child: new RaisedButton(
                  child: new Text('X'),
                  onPressed: () {
                    showDialog<Null>(
                      context: context,
                      child: new AlertDialog(
                        title: new Text('Title'),
                        content: new Text('Y'),
                        actions: <Widget>[ ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('X'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1));

    final StatefulElement widget = tester.element(find.byType(Material).last);
    final Material materialconfig = widget.state.config;
    //first and second expect check that the material is the dialog's one
    expect(materialconfig.type, MaterialType.card);
    expect(materialconfig.elevation, 24);
    expect(materialconfig.color, Colors.grey[800]);
  });

  testWidgets('Simple dialog control test', (WidgetTester tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Center(
            child: new RaisedButton(
              onPressed: null,
              child: new Text('Go'),
            ),
          ),
        ),
      ),
    );

    final BuildContext context = tester.element(find.text('Go'));

    final Future<int> result = showDialog(
      context: context,
      child: new SimpleDialog(
        title: new Text('Title'),
        children: <Widget>[
          new SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, 42);
            },
            child: new Text('First option'),
          ),
          new SimpleDialogOption(
            child: new Text('Second option'),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Title'), findsOneWidget);
    await tester.tap(find.text('First option'));

    expect(await result, equals(42));
  });

  testWidgets('Barrier dismissible', (WidgetTester tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Center(
            child: new RaisedButton(
              onPressed: null,
              child: new Text('Go'),
            ),
          ),
        ),
      ),
    );

    final BuildContext context = tester.element(find.text('Go'));

    showDialog<Null>(
      context: context,
      child: new Container(
        width: 100.0,
        height: 100.0,
        alignment: FractionalOffset.center,
        child: new Text('Dialog1'),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Dialog1'), findsOneWidget);

    // Tap on the barrier.
    await tester.tapAt(const Point(10.0, 10.0));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Dialog1'), findsNothing);

    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      child: new Container(
        width: 100.0,
        height: 100.0,
        alignment: FractionalOffset.center,
        child: new Text('Dialog2'),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Dialog2'), findsOneWidget);

    // Tap on the barrier, which shouldn't do anything this time.
    await tester.tapAt(const Point(10.0, 10.0));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Dialog2'), findsOneWidget);

  });
}
