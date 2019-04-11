FQTween = {}
FQTween.TAG_DEF = "FQTween"

function FQTween:run(node, action)
	if node == nil or action == nil then
		return
	end

	local impl = {}
	impl.node = node
	impl.action = action
	impl.last_frame_time = FQUtils:get_time()
	impl.action:start(node)
	FQUpdater:register(node, impl, self.TAG_DEF)

	function impl:update()
		if self.node:get_visible() == false then
			return
		end
		
		local current_time = FQUtils:get_time()
		local dt = current_time - self.last_frame_time
		self.last_frame_time = current_time
		self.action:update(dt)

        if self.action:is_done() == true then
            self.action = nil
            FQUpdater:unregister(node, impl)
        end
	end
end

function FQTween:stop(node)
	FQUpdater:unregister_with_tag(node, self.TAG_DEF)
end