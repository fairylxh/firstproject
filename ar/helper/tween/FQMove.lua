FQMove = {}

function FQMove:create(duration, delta_pos)
	local impl = {}
	impl.node = nil
	impl.duration = duration
	impl.elapsed = 0
    impl.progress = 0
    impl.is_frist_tick = true
    impl.start_pos = nil
    impl.delta_pos = delta_pos

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
    	self.start_pos = node.position
    end

    function impl:update(dt)
        if self.elapsed >= self.duration and self.is_frist_tick == false then
            return
        end
        self.is_frist_tick = false
        self.elapsed = self.elapsed + dt
        self.progress = math.max(0, math.min(1, self.elapsed / math.max(self.duration, FQMath.epsilon)))
        self:step(self.progress)
    end

    function impl:step(time)
        if self.node == nil then
        	return
        end
        self.node.position = self.start_pos + self.delta_pos * time
    end

    function impl:is_done()
    	return self.elapsed >= self.duration
    end

    return impl
end