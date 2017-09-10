local insert, remove = table.insert, table.remove


local List = {}
List.__index = function(tab, key)
  return rawget(List, key) or (tab._store.pairs[key] and tab[tab._store.pairs[key]])
end




function List:new(generator)
  generator = generator or function(_,i)
    return tostring(i)
  end

  local obj = setmetatable({}, List)

  obj._store = {
    generator = generator;
    n = 0;
    empty = {};
    pairs = {};
  }

  return obj
end











function List:write(data)
  local index
  if self._store.empty[1] then
    index = self._store.empty[1]
  else
    index = self._store.n + 1
  end

  local id = self._store.generator(data, index)
  if type(id) == 'number' then id = tostring(id) end
  if self[id] and self[id] ~= false then
    -- return 'error'
    return nil, 'Tried to enter seemingly duplicate data'
  end

  if self._store.empty[1] then
    remove(self._store.empty,1)
    self._store.empty[tostring(index)] = nil
  else
    self._store.n = self._store.n + 1
  end

  self[index] = data
  self._store.pairs[id] = index

  return self
end











function List:remove(uid)
  if not self[uid] and self[uid] ~= false then
    -- return 'error'
    return nil, 'Tried to remove a non-member'
  end

  local index, id
  if type(uid) == 'number' then
    index = uid
    id = self._store.generator(self[index])
  else
    id = uid
    index = self._store.pairs[id]
  end

  for i,v in ipairs(self._store.empty) do
    if v > index then
      insert(self._store.empty, i, index)
    end
  end
  self._store.empty[tostring(index)] = true

  self._store.pairs[id] = nil
  self[index] = nil

  return self
end










function List:getIndex(id)
  return self._store.pairs[id]
end











function List:iter(prev)
  local index = prev + 1
  local value, id
  done = false
  repeat
    if self[index] then
      value = self[index]
      id = self._store.generator(self[index])
      done = true
    elseif self._store.empty[tostring(index)] then
      index = index + 1
    else
      index = nil
      done = true
    end
  until done
  return index, value, id
end

function List:iterate()
  return self.iter, self, 0
end








































--[[

local test = List:new(function(d) return d.pid end)

test:write{ ['pid'] = 'one' }
    :write{ ['pid'] = 'two' }
    :write{ ['pid'] = 'three' }
    :write{ ['pid'] = 'four' }
    :write{ ['pid'] = 'five' }
    :write{ ['pid'] = 'six' }
    :write{ ['pid'] = 'seven' }
print('Values added')
for k,v in pairs(test) do
  print('Pairs: ', type(k),k,type(v),v)
end

print('Iterator test')
for id, value, index in test:iterate() do
  print('Iterate: ', id, value, index)
end
print('hi')
test:remove('three')
    :remove(7)
print('Value removed')
for k,v in pairs(test) do
  print('Pairs: ', type(k),k,type(v),v)
end

print('Iterator test')
for id, value, index in test:iterate() do
  print('Iterate: ', id, value, index)
end

print(test:write{ ['pid'] = '6' })
print(test:remove('7'))

--]]


return List