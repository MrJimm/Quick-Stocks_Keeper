require 'Utils'

lj = require 'lunajson'
local jsonraw = '{"test": [1,3,2,4]}'
local jsonparse = lj.decode(jsonraw)
print(tableToString(jsonparse))

js = {['main']= {['a']= 1, ['b']= 2, ['c']= {21, 22, 23, 24}}}
local json = lj.encode(js)
print(json)


require 'States'
local s = OpenPositionState:new('open position')
print(s.name)
s = s.processState()
print(s:getName())