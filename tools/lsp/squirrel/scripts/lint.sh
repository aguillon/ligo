#!/usr/bin/env bash

hlint --hint .hlint.yaml . --ignore='Parse error' --ignore-glob="bench/submodules/**"
