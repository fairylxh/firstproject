FQSpawn = {}

function FQSpawn:create( ... )
	local impl = {}
	impl.node = nil
    impl.actions = {}
    impl.duration = 0
    impl.elapsed = 0
    impl.progress = 0
    impl.is_complete = false

    local arg = { ... }
	local n = 0
    for k,v in pairs(arg) do
    	if v ~= nil then
	    	n = n + 1
	    	impl.actions[n] = v
            if impl.duration < v:get_duration() then
                impl.duration = v:get_duration()
            end
	    end
    end

    function impl:get_duration()
        return self.duration
    end

    function impl:get_progress()
        return self.progress
    end

    function impl:start(node)
    	self.node = node
        self.elapsed = 0
        self.progress = 0
        self.is_complete = false
        for i=1, #self.actions, 1 do
    	   self.actions[i]:start(node)
        end
    end

    function impl:update(dt)
        if self.is_complete == true then
            self.progress = 1
            return
        end
        self.elapsed = self.elapsed + dt
        self.progress = math.max(0, math.min(1, self.elapsed / math.max(self.duration, FQMath.epsilon)))

        local is_complete = true
        for i=1, #self.actions, 1 do
           self.actions[i]:update(dt)
           if self.actions[i]:is_done() == false then
                is_complete = false
            end
        end
        self.is_complete = is_complete
    end

    function impl:is_done()
    	return self.is_complete
    end

    return impl
end