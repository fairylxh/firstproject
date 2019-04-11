-----------------------------
----- 一个空的Action -----
-----------------------------

FQAction = {}

function FQAction:create()
	local impl = {}
	impl.node = nil
	impl.duration = 0
	impl.elapsed = 0
    impl.progress = 0
    impl.is_frist_tick = true

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
    end

    function impl:is_done()
    	return self.elapsed >= self.duration
    end

    return impl
end