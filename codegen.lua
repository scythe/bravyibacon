bch = require "bch"
matmul = require "matmul"
gausselim = require "gausselim"

local codegen = {}

function codegen.genmat(exp, dist)
   local add, get = gausselim.esearch(2^exp - 1)
   print(exp, type(exp), dist, type(dist))
   local p, pi = bch.bchpoly(exp, dist)
   repeat
      pi, p = p, p-1
      add(setmetatable(pi, gausselim.Vector))
   until pi[2^exp - 1] == 1
   local mat = matmul.construct(get())
   print("" .. mat)
   local transmat = matmul.transpose(mat)
   print("" .. transmat, "" .. mat)
   local bbmat = transmat * mat
   print("" .. mat, "" .. transmat, "" .. bbmat)
   return bbmat
end

return codegen
