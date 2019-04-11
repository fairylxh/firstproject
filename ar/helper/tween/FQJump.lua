FQJump = {}

function FQJump:create(duration, delta_pos, crest_pos)
	local impl = {}
	-- 公参
	impl.node = nil
	impl.duration = duration
	impl.elapsed = 0
    impl.progress = 0
    impl.is_frist_tick = true
	-- 私参
    impl.start_pos = nil
    impl.delta_pos = delta_pos
    impl.crest_pos = crest_pos

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

        local x = self.delta_pos.x * time
        local y = self.delta_pos.y * time
        local z = self.delta_pos.z * time

        local frac = time % 1.0
        local n = 4 * frac * (1 - frac)
        x = x + self.crest_pos.x * n
        y = y + self.crest_pos.y * n
        z = z + self.crest_pos.z * n

        self.node.position = self.start_pos + Vector3(x, y, z)
    end

    function impl:is_done()
    	return self.elapsed >= self.duration
    end

    return impl
end