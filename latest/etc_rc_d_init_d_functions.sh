#!/bin/sh

success() {
    echo "success: $@"
}

failure() {
    echo "failure: $@"
    exit 1
}
