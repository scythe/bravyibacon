#!/usr/local/bin/luajit
codegen = require "codegen"

m = codegen.genmat(arg[1] + 0, arg[2] + 0)

print(m .. "")
