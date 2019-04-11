FQSequence = {}

function FQSequence:create( ... )
	local impl = {}
	impl.node = nil
    impl.actions = {}
    impl.duration = 0
    impl.elapsed = 0
    impl.progress = 0
    impl.action_index = 1
    impl.current_action = nil
    

    local arg = { ... }
	local n = 0
    for k,v in pairs(arg) do
    	if v ~= nil then
	    	n = n + 1
	    	impl.actions[n] = v
            impl.duration = impl.duration + v:get_duration()
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
    	self.action_index = 1
    	self.current_action = self.actions[self.action_index]
    	self.current_action:start(node)
    end

    function impl:update(dt)
        if self.current_action == nil then
            return
        end
        self.elapsed = self.elapsed + dt
        self.progress = math.max(0, math.min(1, self.elapsed / math.max(self.duration, FQMath.epsilon)))

        self.current_action:update(dt)
        if self.current_action:is_done() == true then
            self.action_index = self.action_index + 1
            if self.action_index <= #self.actions then
                self.current_action = self.actions[self.action_index]
                self.current_action:start(self.node)
            else
                self.current_action = nil
            end
        end
    end

    function impl:is_done()
    	return (self.action_index > #self.actions)
    end

    return impl
end