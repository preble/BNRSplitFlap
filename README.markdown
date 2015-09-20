# BNRSplitFlap

Created by Adam Preble and Andrew Lunsford for Big Nerd Ranch's Clash of the Coders, April 18-20th 2012.

## SplitFlap

iPhone client (not tested on iPad) which connects to the server and displays a single digit.

libzmq.a is packaged with it and is only built for ARM so it will only run on the device.

## SplitFlapPadController

iPad controller, to which SplitFlap devices connect to in order to receive commands.

libzmq.a is packaged with it and is only built for ARM so it will only run on the device.

## CocoaSplitFlapController

Cocoa controller app used in development prior to SplitFlapPadController's existence.

Links to libzmq.dylib and libcmzq.dylib.  To install:

    brew install zmq czmq

## AudibleTesting

iOS app created to test sound levels.

## BlueToothTestSearch

iOS app created in the interest of testing Bluetooth device signal strength (did not work).
