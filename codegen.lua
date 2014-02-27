bch = require "bch"
matmul = require "matmul"
gausselim = require "gausselim"

function genmat(exp, dist)
   local add, get = gausselim.esearch(2^exp - 2)
   local p = bch.bchpoly(exp, dist)
   local rank = 2^exp - 1 - #p
   for i = 0, rank do
      add(setmetatable(p-i, Vector))
   end
   local mat = matmul.construct(get())
   local bbmat = matmul.transpose(mat) * mat
   return bbmat
end

return {genmat = genmat}
