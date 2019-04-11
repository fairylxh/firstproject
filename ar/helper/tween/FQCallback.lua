FQCallback = {}

function FQCallback:create(delay,func)
    if delay == nil then
        delay = 0
    end
	local impl = {}
	impl.node = nil
	impl.duration = delay
	impl.elapsed = 0
    impl.progress = 0
    impl.is_frist_tick = true
	impl.func = func

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
        self.is_frist_tick = true
    end

    function impl:update(dt)
        if self.elapsed >= self.duration and self.is_frist_tick == false then
            return
        end
        self.is_frist_tick = false
        self.elapsed = self.elapsed + dt
        self.progress = math.max(0, math.min(1, self.elapsed / math.max(self.duration, FQMath.epsilon)))

        if self.elapsed >= self.duration then
            if self.func ~= nil then
                self.func()
            end
        end
    end

    function impl:is_done()
    	return self.elapsed >= self.duration
    end

    return impl
end