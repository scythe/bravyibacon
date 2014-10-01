bch = require "bch"
matmul = require "matmul"
gausselim = require "gausselim"

local codegen = {}

function codegen.genmat(exp, dist)
   local add, get = gausselim.esearch(2^exp - 1)
   local p, pi = bch.bchpoly(exp, dist)
   repeat
      pi, p = p, p-1
      add(setmetatable(pi, gausselim.Vector))
   until pi[2^exp - 1] == 1
   local mat = matmul.construct(get())
   local transmat = matmul.transpose(mat)
   local bbmat = transmat * mat
   return bbmat
end

return codegen
