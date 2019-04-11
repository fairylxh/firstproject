
FQRotate = {}

function FQRotate:create(duration, delta_angle)
	local impl = {}
	impl.node = nil
	impl.duration = 0
	impl.elapsed = 0
    impl.progress = 0
    impl.is_frist_tick = true
    impl.delta_angle = delta_angle
    impl.rotate_by_amin = nil

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

        if self.is_frist_tick == true then
            self.start_angle = Vector3(self.node:get_world_rotation())
        end

        self.is_frist_tick = false
        self.elapsed = self.elapsed + dt
        self.progress = math.max(0, math.min(1, self.elapsed / math.max(self.duration, FQMath.epsilon)))
        
        local angle = self.start_angle + self.delta_angle * self.progress
        self.node:set_rotation_by_xyz(angle.x, angle.y, angle.z)
    end

    function impl:is_done()
    	return self.elapsed >= self.duration
    end

    return impl
end