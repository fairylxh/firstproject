
FQFrameAnim = {}

function FQFrameAnim:create(spriteNode, frames)
	if spriteNode == nil or frames == nil then
		return nil
	end

	local FrameAnim = {}
	FrameAnim.frames = frames
	FrameAnim.curFrameIndex = 1
	FrameAnim.lastTime = 0
	FrameAnim.isRunning = false
	FrameAnim.frameInterval = 1
	FrameAnim.frameCount = #frames
	FrameAnim.spriteNode = spriteNode
	FrameAnim.callback = nil
	FrameAnim.times = 0
	FrameAnim.count = 0
	FrameAnim.follow_target = nil
	FrameAnim.follow_pos_offset = nil
	FrameAnim.click_callback = nil
	
	spriteNode:set_visible(false)
	FQUpdater:register(spriteNode, FrameAnim)

	function FrameAnim:update()
		if self.isRunning == false then
			return
		end

		local curTime = FQUtils:get_time()
		local deltaTime = curTime - self.lastTime
		if deltaTime >= self.frameInterval then
			self.lastTime = curTime
			self.curFrameIndex = self.curFrameIndex + 1

			if self.curFrameIndex > self.frameCount then
				self.count = self.count + 1

				if self.count == self.times then
					self.isRunning = false
					self.curFrameIndex = 1
					self.spriteNode:set_visible(false)
					if self.callback ~= nil then
						self.callback()
					end
					return
				else
					self.curFrameIndex = 1
				end
			end

			if self.curFrameIndex >= 1 and self.curFrameIndex <= self.frameCount then
				self.spriteNode:replace_texture(self.frames[self.curFrameIndex],"uDiffuseTexture")
			end
		end

		if self.follow_target ~= nil then
			local pos_str = self.follow_target:get_world_position()
			local world_pos = Vector3(pos_str)
			local screen_pos = app:get_current_scene():project(world_pos.x, world_pos.y, world_pos.z)
			if self.follow_pos_offset ~= nil then
				screen_pos.x = screen_pos.x + self.follow_pos_offset.x
				screen_pos.y = screen_pos.y + self.follow_pos_offset.y
				screen_pos.z = screen_pos.z + self.follow_pos_offset.z
			end
			self.spriteNode:set_hud_position(screen_pos.x, screen_pos.y)
		end
	end

	-- 设置序列帧播放一次的时间
	function FrameAnim:set_duration(duration)
		duration = duration / 1000
		self.frameInterval = duration / self.frameCount
	end

	-- 设置序列帧循环播放次数（<=0 无限循环播放）
	function FrameAnim:set_loop_times(times, callback)
		self.times = times
		self.callback = callback
	end

	-- 获取所绑定的图片节点
	function FrameAnim:get_node()
		return self.spriteNode
	end

	-- 获取播放次数（一个循环为一次）
	function FrameAnim:get_play_count()
		return self.count
	end

	-- 是否正在播放动画
	function FrameAnim:is_playing()
		return self.isRunning
	end

	function FrameAnim:set_frame_index(index)
		self.curFrameIndex = index
	end

	-- 开始播放动画
	function FrameAnim:start()
		self.lastTime = FQUtils:get_time()
		self.count = 0;
		self.spriteNode:replace_texture(self.frames[self.curFrameIndex],"uDiffuseTexture")
		self.spriteNode:set_visible(true)
		self.isRunning = true

		if self.follow_target ~= nil then
			local pos_str = self.follow_target:get_world_position()
			local world_pos = Vector3(pos_str)
			local screen_pos = app:get_current_scene():project(world_pos.x, world_pos.y, world_pos.z)
			if self.follow_pos_offset ~= nil then
				screen_pos.x = screen_pos.x + self.follow_pos_offset.x
				screen_pos.y = screen_pos.y + self.follow_pos_offset.y
				screen_pos.z = screen_pos.z + self.follow_pos_offset.z
			end
			self.spriteNode:set_hud_position(screen_pos.x, screen_pos.y)
		end
	end

	-- 停止播放动画
	function FrameAnim:stop()
		self.isRunning = false
		self.curFrameIndex = 1
		self.spriteNode:set_visible(false)
	end

	-- 暂停播放动画
	function FrameAnim:pause()
		self.isRunning = false
	end

	-- 恢复播放动画
	function FrameAnim:resume()
		self.isRunning = true
	end

	-- 恢复播放动画
	function FrameAnim:set_hud_follow(target, offset)
		if offset == nil then
			offset = Vector3(0,0,0)
		end
		self.follow_target = target
		self.follow_pos_offset = offset

		if self.follow_target ~= nil then
			local pos_str = self.follow_target:get_world_position()
			local world_pos = Vector3(pos_str)
			local screen_pos = app:get_current_scene():project(world_pos.x, world_pos.y, world_pos.z)
			if self.follow_pos_offset ~= nil then
				screen_pos.x = screen_pos.x + self.follow_pos_offset.x
				screen_pos.y = screen_pos.y + self.follow_pos_offset.y
				screen_pos.z = screen_pos.z + self.follow_pos_offset.z
			end
			self.spriteNode:set_hud_position(screen_pos.x, screen_pos.y)
		end
	end

	function FrameAnim:set_click_event(callback)
		self.click_callback = callback
		self.spriteNode.on_click = function ()
			if self.click_callback ~= nil then
				self.click_callback()
			end
		end
	end

	function FrameAnim:set_visible(visible)
		self.spriteNode:set_visible(visible)
	end

	function FrameAnim:get_visible()
		return self.spriteNode:get_visible()
	end

	return FrameAnim
end