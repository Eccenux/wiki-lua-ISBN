local function list2map(list)
	local map = {}
	if list then
		for _, v in ipairs(list) do
			map[v] = true
		end
	end
	
	return map
end

return list2map(mw.loadData("Moduł:ISBN/usprawiedliwiony-niepoprawny"))
