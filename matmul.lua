gausselim = require "gausselim.lua"

local Vector = gausselim.Vector

Matrix = {
__index = function(self, tuple)
   local ret
   if(tuple[1] and not tuple[2]) then
      ret = setmetatable({}, Vector)
      for i = 1, rawget(self, "cols") do
         ret[i] = rawget(self, tuple[1] * rawget(self, "cols") + i)
      end
   elseif(tuple[2] and not tuple[1]) then
      ret = setmetatable({}, Vector)
      for i = 1, rawget(self, "rows") do
          ret[i] = rawget(self, tuple[2] + (i-1) * rawget(self, "cols"))
      end
   elseif(tuple[1] and tuple[2]) then
      ret = rawget(self, (tuple[1]-1) * rawget(self, "cols") + tuple[2])
   end
   return ret
end,
__newindex = function(self, tuple, val)
   rawset(self, (tuple[1]-1) * rawget(self, "cols") + tuple[2], val)
end,
__add = function(ml, mr)
   if(getmetatable(ml) == getmetatable(mr) and #ml == #mr and #ml[{1}] = #mr[{1}]) then
     local ret = Vector.__add(ml, mr)
     for k, v in pairs(ml) do
        if(type(k) ~= "table") then
           rawset(ret, k, v)
        end
     end
     return ret
   end
end,
__mul = function(ml, mr)
   if(getmetatable(ml) ~= getmetatable(mr)) then return nil end
   ret = {rows = rawget(ml, "rows"), cols = rawget(ml, "cols")}
   ret.len = ret.rows * ret.cols
   setmetatable(ret, getmetatable(ml))
   for i = 1, #ml[{nil, 1}] do
      for j = 1, #mr[{1}] do
         ret[{i, j}] = ml[{i}] * mr[{nil, j}]
      end
   end
   return ret
end}

construct = function(v, rows, cols)
   if(type(v) == "table" and #v = rows * cols) then
      v.rows = rows
      v.cols = cols
      return setmetatable(v, Matrix)
   end
end

return {Matrix = Matrix, construct = construct}
