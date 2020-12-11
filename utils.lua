function tableToString(tab)
	local res = ""
	for k, v in pairs(tab) do
    str_val = ""
    if (type(v) == 'table') then
      str_val = tableToString(v)
    else
      str_val = tostring(v)
    end
    
		res = res .. tostring(k) .. ': ' .. str_val .. '; '
	end
	return "{ " .. res .. " }"
end

function extended (child, parent)
    setmetatable(child,{__index = parent}) 
end

function wlog(msg, level)
  level = level or 0
  print('logging message of level ' .. tostring(level) .. ' TODO')
end