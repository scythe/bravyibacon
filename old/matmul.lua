gausselim = require "gausselim"

local Vector = gausselim.Vector

local matmul = {}

matmul.Matrix = {
__index = function(self, tuple)
   local ret
   if(tuple[1] and not tuple[2]) then
      ret = setmetatable({}, Vector)
      for i = 1, rawget(self, "cols") do
         ret[i] = rawget(self, (tuple[1]-1) * rawget(self, "cols") + i)
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
   if(getmetatable(val) == Vector) then
      if(not tuple[2]) then
         for i = 1, rawget(self, "cols") do
            rawset(self, (tuple[1]-1) * rawget(self, "cols") + i, val[i] or 0)
         end
      elseif(not tuple[1]) then
         for i = 1, rawget(self, "rows") do
             rawset(self, (i-1) * rawget(self, "cols") + tuple[2], val[i] or 0)
         end
      end
   else
      rawset(self, (tuple[1]-1) * rawget(self, "cols") + tuple[2], val)
   end
end,
__add = function(ml, mr)
   if(getmetatable(ml) == getmetatable(mr) and #ml == #mr and #ml[{1}] == #mr[{1}]) then
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
   local ret = {rows = rawget(ml, "rows"), cols = rawget(mr, "cols")}
   ret.len = ret.rows * ret.cols
   setmetatable(ret, getmetatable(ml))
   for i = 1, #ml[{nil, 1}] do
      for j = 1, #mr[{1}] do
         ret[{i, j}] = ml[{i}] * mr[{nil, j}]
      end
   end
   return ret
end,
__concat = function(mat, str)
   if(type(str) ~= "string") then return (mat .. "") .. (str .. "") end
   s = "{"
   for i = 1, #mat[{nil, 1}] do
      s = s .. "\n{"
      for k, v in ipairs(mat[{i}]) do
         s = s .. ({[0] = '0,', [1] = '1,'})[v or 0]
      end
      s = s .. "nil},"
   end
   s = s .. "nil}"
   return s .. str
end
}


matmul.construct = function(v, rows, cols)
   if(type(v) == "table" and #v == rows * cols) then
      v.rows = rows
      v.cols = cols
      v = setmetatable(v, matmul.Matrix)
      return v
   end
end

matmul.transpose = function(mat)
   local ret = setmetatable({rows = #mat[{1}], cols = #mat[{nil, 1}]}, matmul.Matrix)
   for i = 1, #mat[{1}] do
      ret[{i}] = mat[{nil, i}]
   end
   return ret
end

return matmul
