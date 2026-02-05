#!/bin/bash

#src/app.js tests

EXPECTED="Hello, Test!"

OUTPUT=$(node -e "console.log(require('./src/app')('Test'))")

if[ "$OUTPUT" == "$EXPECTED" ]; then
    echo "Test passed"
    exit 0
else
    echo "Test failed: expected '$EXPECTED' but got '$OUTPUT'"
    exit 1
fi