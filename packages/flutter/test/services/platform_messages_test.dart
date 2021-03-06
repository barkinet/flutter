// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:test/test.dart';

void main() {
  test('Mock binary message handler control test', () async {
    final List<ByteData> log = <ByteData>[];

    PlatformMessages.setMockBinaryMessageHandler('test1', (ByteData message) async {
      log.add(message);
    });

    final ByteData message = new ByteData(2)..setUint16(0, 0xABCD);
    await PlatformMessages.sendBinary('test1', message);
    expect(log, equals(<ByteData>[message]));
    log.clear();

    PlatformMessages.setMockBinaryMessageHandler('test1', null);
    await PlatformMessages.sendBinary('test1', message);
    expect(log, isEmpty);
  });
}
