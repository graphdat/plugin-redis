local Redis = require('../')

local client = Redis:new()

client:on('error', function (err)
    print('Error (error callback): ', err)
end)

client:registerCommand('myget', [[
  local x = redis.call('get', KEYS[1])
  if not x then x = '(N/A)' end
  return x
]], 1, function(err)
  if err then p('ERR', err) ; return end
  client:myget('foo1', Redis.print) -- (N/A)
  client:myget('foo2', Redis.print) -- (N/A)
end)

client:registerCommandFromFile('mycustom', __dirname .. '/../params.lua', 3, function(err)
  if err then p('ERR', err) ; return end
  client:mycustom('foo1', 'foo2', 'foo3', 'bar1', 'bar2', function(err, result)
    assert(not err)
    p(result)
  end)
end)

client:registerCommandFromFile('mycustom1', __dirname .. '/../params.lua', 2, function(err)
  if err then p('ERR', err) ; return end
  client:mycustom1({ 'foo1', 'foo2', 'foo3', 'bar1', 'bar2' }, function(err, result)
    assert(not err)
    p(result)
  end)
end)
