local metamethods = {
   '__index', '__tostring', '__len', '__unm', 
   '__add', '__sub', '__mul', '__div', '__mod',
   '__pow', '__concat', '__eq', '__lt', '__le',
   '__call', '__gc', '__newindex', '__mode'
}

local function rget(t, key)
   if t == nil then return nil end
   local rv = t[key]
   if rv == nil then return rget(t._parent, key)
   else return rv end
end

local construct = function(t)
   local rv = {}
   for key, method in pairs(metamethods) do
      rv[method] = rget(t, method)
   end
   return rv
end

Class = function(def, parent)
   local def = def or {}
   local subclass = parent ~= nil
   local parent = parent or {}
   def.__init__ = def.__init__ or parent.__init__ or function(self) end

   setmetatable(def, {
      __call = function(cls, ...)
         local rv = {}
         if subclass then
            rv._parent = parent(...)
         end
         for key, val in pairs(cls) do
           rv[key] = val
         end
         setmetatable(rv, construct(rv))
         def.__init__(rv, ...)
         return rv
      end,
   })
   return def
end

-- Simplify coroutine usage, especially for use with classes

yield = function(...)
   local arg = {...}
   if #arg == 1 then coroutine.yield(...)
   else coroutine.yield(arg)
   end
end
 
Generator = function(f)  
   local cor = coroutine.create(f)
   return function(...)
      local status, val = coroutine.resume(cor, ...)
      return val
   end
end