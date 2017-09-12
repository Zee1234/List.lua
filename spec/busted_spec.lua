local List = require('list')

local function genericGenerator(_, d) return d end -- Identical to List's default generator
local function gen(d) return d end -- Returns all data to use as key, good for testing

math.randomseed(os.clock()*1000)
math.random()
math.random()
math.random()


describe('New instances', function()
  it('are checked to be identical, but not equal', function()
    assert.are.same(List.new(genericGenerator), List.new(genericGenerator), {
      _store = {
        generator = genericGenerator;
        n = 0;
        empty = {};
        pairs = {};
      }
    })

    assert.are.unique(List.new(genericGenerator), List.new(genericGenerator))
  end)
end)





describe('With new instances,', function()
  it('checks that (de)population occurs identically', function()
    local listA = List.new(gen):write('1'):write('2'):write('3')
    local listB = List.new(gen):write('1'):write('2'):write('3')
    assert.are.same(listA, listB)

    assert.are.same(listA:remove('1'), listB:remove('1'))
  end)
end)





describe('Chained methods', function()
  it('continue to function if no error', function()
    assert.is.truthy(
      List.new(gen)
          :write('a')
          :write('b')
          :write('c')
          :write('d')
          :remove('d')
          :remove(3)
          :write('c')
          :write('d')
    )
  end)



  it('insert into removed spaces properly', function()
    local listA = List.new(gen)
                      :write('a')
                      :write('b')
                      :write('c')
                      :write('d')
                      :remove('b')
                      :remove('c')
                      :write('e')
    local store = listA._store
    assert.are.same(listA, {
      'a', 'e', nil, 'd', _store = store
    })
  end)
end)

describe('`removeReturn`', function()
  it('removes properly',function() 
    local listA = List.new(gen):write('a')
    local ret = listA:removeReturn('a')
    local store = listA._store
    assert.are.same(listA, {
      _store = store
    })
  end)



  it('returns properly', function()
    local listA = List.new(gen):write('a')
    local arbitrary = {
      [math.random()] = math.random();
      [math.random()] = math.random();
    }
    listA:write(arbitrary)
    local ret = listA:removeReturn(2)

    local listB = List.new(gen):write('a')
    listB:write('b'):remove('b')

    assert.are.equals(ret, arbitrary)
    assert.are.same(listA, listB)
  end)
end)

describe('`getIndex`', function()
  it('returns index correctly', function()
    local listA = List.new(gen)
                      :write('a')
                      :write('b')
                      :write('c')
                      :write('d')
                      :remove('b')
                      :remove('c')
                      :write('e')
    
    assert.is.truthy(listA:getIndex('e') == 2)
    assert.is.truthy(listA:getIndex('b') == nil)
  end)
end)





describe('Iteration:', function()
  describe('`next`:', function()
    it('returns next element', function()
      local vals = {'a', 'b', 'c', 'd', 'e'}
      local listA = List.new(gen)
                        :write(vals[1])
                        :write(vals[2])
                        :write(vals[3])
                        :write(vals[4])
                        :remove(vals[2])
                        :remove(vals[3])
                        :write(vals[5])
      
      for index, value, id in listA.next, listA, 0 do
        local i = 1
        assert.are.equals(listA[index], value, listA[id], id, listA[i], vals[1])
        break;
      end
      for index, value, id in listA.next, listA, 1 do
        local i = 2
        assert.are.equals(listA[index], value, listA[id], id, listA[i], vals[5])
        break;
      end
      for index, value, id in listA.next, listA, 2 do
        local i = 4
        assert.are.equals(listA[index], value, listA[id], id, listA[i], vals[4])
        break;
      end
    end)



    it('is returned by `iterate`', function()
      local listA = List.new()
      local next, tab = List:iterate()

      assert.are.same(next, List.next)
    end)
  end)


  describe('`iterate`', function()
    it('properly iterates over straight writes', function()
      local listA = List.new(gen)
      local vals = {}
      for i=65, 122, 1 do
        table.insert(vals, string.char(i)..tostring(i-64))
        listA:write(vals[#vals])
      end
      
      for index, value, id in listA:iterate() do
        assert.are.same(listA[index], listA[id], value, vals[index])
      end
    end)



    it('properly iterates over skipped values', function()
      local listA = List.new(gen)
      local vals = {}
      for i=65, 122, 1 do
        table.insert(vals, string.char(i)..tostring(i-64))
        listA:write(vals[#vals])
      end

      for index, value, id in listA:iterate() do
        assert.are.same(listA[index], listA[id], value, vals[index])
      end

      local removes = {}
      for i=1, 30, 1 do
        local num = math.random(1,122-65)
        if not removes[tostring(num)] then
          removes[tostring(num)] = true
          table.insert(removes, num)
        end
      end

      for _, v in ipairs(removes) do
        listA:remove(v)
      end

      local keptVals, listVals = {}, {}
      for i, v in ipairs(vals) do
        if not removes[tostring(i)] then
          table.insert(keptVals, v)
        end
      end
      for index, value, id in listA:iterate() do
        table.insert(listVals, value)
      end

      assert.are.same(listVals, keptVals)
    end)
  end)
end)





describe('Default generator', function()
  it('functions properly', function()
    local listA = List.new():write('a'):write('b')
    assert.are.same(listA[1], listA['1'])
    assert.are.same(listA[2], listA['2'])
  end)
end)





describe('Errors (nil returned)', function()
  local listA = List.new(gen):write('a'):write('b')

  it('when defining value with same ID', function()
    local ret, str = listA:write('a')
    assert.is.truthy(ret == nil)
    assert.is.truthy(type(str) == 'string')
  end)


  it('when removing non-member', function()
    local ret, str = listA:remove(100)
    assert.is.truthy(ret == nil)
    assert.is.truthy(type(str) == 'string')

    local ret2, str2 = listA:removeReturn(100)
    assert.is.truthy(ret2 == nil)
    assert.is.truthy(type(str2) == 'string')

  end)


  it('when trying to write a value that cannot be converted into an ID by the generator', function()
    local listB = List.new(function(data)
      return data.name
    end)
    listB:write { name = 'hi' }
    local ret, str = listB:write{}
    assert.is.truthy(ret == nil)
    assert.is.truthy(type(str) == 'string')
  end)
end)