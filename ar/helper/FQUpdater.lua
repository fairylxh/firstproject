
FQUpdater = {}
FQUpdater.updater_cache_list = {}

function FQUpdater:register(node, t, tag)
	if node == nil then
		return nil
	end

	local Updater = FQUpdater.updater_cache_list[node]
	if Updater ~= nil then
		for k, obj in pairs(Updater.object_list) do
			if obj == t then
				return
			end
		end
		if tag ~= nil then
			Updater.object_list[tag] = nil
			Updater.object_list[tag] = t
		else
			table.insert(Updater.object_list, t)
		end
		Updater.object_count = Updater.object_count + 1
		return
	end

	Updater = {}
	Updater.node = node
	Updater.object_list = {}
	Updater.invalid_list = {}
	Updater.object_count = 0
	Updater.tatget_type = 0
	if tag ~= nil then
		Updater.object_list[tag] = nil
		Updater.object_list[tag] = t
	else
		table.insert(Updater.object_list, t)
	end
	Updater.object_count = Updater.object_count + 1
	FQUpdater.updater_cache_list[node] = Updater

	node.on_update = function ()
		Updater:_update()
	end

	function Updater:_update()
		for k, t in pairs(self.object_list) do
			local invalid = true
			if t ~= nil then
				if type(t) == "table" and t.update ~= nil then
					t:update()
					invalid = false
				elseif type(t) == "function" then
					t()
					invalid = false
				end
			end
			if invalid == true then
				table.insert(self.invalid_list, t)
			end
		end

		for k, t in pairs(self.invalid_list) do
			table.remove(self.object_list, k)
		end
		self.invalid_list = {}

		if self.object_count <= 0 then
			table.remove(FQUpdater.updater_cache_list, self.node)
		end
	end
end

function FQUpdater:unregister(node, t)
	if node == nil then
		return
	end

	local Updater = FQUpdater.updater_cache_list[node]
	if Updater == nil then
		return
	end

	for k, obj in pairs(Updater.object_list) do
		if obj == t then
			table.remove(Updater.object_list, k)
			Updater.object_count = Updater.object_count - 1
			return
		end
	end
end

function FQUpdater:unregister_with_tag(node, tag)
	if node == nil or tag == nil then
		return
	end

	local Updater = FQUpdater.updater_cache_list[node]
	if Updater == nil then
		return
	end

	Updater.object_list[tag] = nil
end