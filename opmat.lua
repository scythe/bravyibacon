gausselim = require "gausselim"
matmul = require "matmul"

function enumerators(bmat)
   numt = {}
   post = {}
   i = 1

   for row, v in ipairs(bmat) do
      for col, val in ipairs(v) do
         if(val == 1) then
            numt[i] = {row, col}
            post[(row-1)*#bmat + col] = i
            i = i + 1
         else
            post[(row-1)*#bmat + col] = 0
         end
      end
   end

   post = matmul.construct(post, #bmat, #bmat) --bravyi matrices must be square!

   local posf = function(ind)
      if(type(ind) == "table") then return ind end
      if(type(ind) == "number") then return numt[ind] end
   end

   local numf = function(indt)
      if(type(indt) == "number") then return indt end
      if(type(indt) == "table" and #indt == 2) then print(indt[1], indt[2], "indexes"); return post[indt] end
   end

   return {pos = posf, num = numf, qubits = #numt, rows = #bmat}
end

function rank(benum)
   if benum.rank then print("stupid"); return benum.rank end
   local ret = benum.rows
   for row = 1, benum.rows do
      if(row >= ret) then break end
      local pivotnum = benum.num({row, row})
      print("pivotnum" .. pivotnum)
      ret = math.min(ret, (benum.pos(pivotnum+1))[2])
      print(ret)
   end
   benum.rank = ret - 1
   return benum.rank
end

--We use the original convention that logical X is on columns and logical Z is on rows.
--op = 'x', 'z'

function olog(benum, op) 
   local n = benum.qubits
   local k = rank(benum)
   print(k)
   local ol = {}
   local ax = {x = 2, z = 1}
   for i = 1, k do
      ol[i] = setmetatable({}, gausselim.Vector)
      for j = 1, n do
         ol[i][j] = (benum.pos(j))[ax[op]] == i and 1 or 0
      end
   end
   return ol
end

function ostab(benum, ol, op) 
   print("called ostab", benum)
   local k = rank(benum)
   io.stderr:write(k .. "it executes\n")
   local ax = {x = 2, z = 1}
   os = {}
   ol = ol or olog(benum, op)
   for i = k+1, benum.rows do
      print("yay")
      os[i-k] = setmetatable({}, gausselim.Vector)
      for j = 1, benum.qubits do
         os[i-k][j] = (benum.pos(j))[ax[op]] == i and 1 or 0
         print("os[" .. i-k .. "][" .. j .."] = " .. os[i-k][j])
      end
      for j = 1, k do
         if(benum.num({[3-ax[op]] = i,[ax[op]] = j}) ~= 0) then
            os[i-k] = os[i-k] + ol[j]
            print(3-ax[op], ax[op], benum.num{[3-ax[op]] = i, [ax[op]] = j})
            print(table.concat(os[i-k], " "), "os[i]")
         end
      end
   end
   print(#os)
   return os, ol
end

function ogauge(benum, op) 
   local og = {}
   local row = 1
   local ax = {x = 1, z = 2}
   local nextnum = function(pos)
      local npos = {pos[1], pos[2]}
      repeat
         npos[ax[op]] = npos[ax[op]] + 1
         print("npos", ax[op], unpack(npos))
         if npos[ax[op]] > benum.rows then return false end
      until benum.num(npos) ~= 0
      print(benum.num(npos))
      return benum.num(npos)
   end
   for i = 2, benum.qubits do 
      local nbit = nextnum(benum.pos(i-1))
      if nbit then
         og[i-row] = {}
         for j = 1, benum.qubits do
            og[i-row][j] = 0
         end
         og[i-row][i-1] = 1
         og[i-row][nbit] = 1
      else
         row = row + 1
      end
   end
   return og
end

return {
enumerators = enumerators,
rank = rank,
xlog = function(benum) return olog(benum, 'x') end,
xstab = function(benum, xl) return ostab(benum, xl, 'x') end,
xgauge = function(benum) return ogauge(benum, 'x') end,
zlog = function(benum) return olog(benum, 'z') end,
zstab = function(benum, zl) return ostab(benum, zl, 'z') end,
zgauge = function(benum) return ogauge(benum, 'z') end
}

