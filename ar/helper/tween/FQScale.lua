FQScale = {}

function FQScale:create(duration, final_scale)
	local impl = {}
	impl.node = nil
	impl.duration = duration
	impl.elapsed = 0
    impl.progress = 0
    impl.is_frist_tick = true
    impl.start_scale = nil
    impl.final_scale = final_scale
    impl.delta_scale = Vector3(0,0,0)

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
    	self.start_scale = node.scale
    	self.delta_scale = self.final_scale - self.start_scale
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
        self.node.scale = self.start_scale + self.delta_scale * time
    end

    function impl:is_done()
    	return self.elapsed >= self.duration
    end

    return impl
end