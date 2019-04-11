FQRepeat = {}

function FQRepeat:create(action, times)
	local impl = {}
    impl.node = nil
	impl.action = action
    impl.duration = action:get_duration()
    impl.elapsed = 0
    impl.progress = 0
	impl.times = times
	impl.count = 0

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
        self.count = 0
        self.action:start(node)
    end

    function impl:update(dt)
        self.elapsed = self.elapsed + dt
        self.progress = math.max(0, math.min(1, self.elapsed / math.max(self.duration, FQMath.epsilon)))

        self.action:update(dt)
        if self.action:is_done() == true then
            self.count = self.count + 1
            if self.count ~= self.times then
                self.action:start(self.node)
            end
        end
    end

    function impl:is_done()
    	return self.count == self.times
    end

    return impl
end