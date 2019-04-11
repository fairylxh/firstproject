

FQPod = {}

function FQPod:create(pod)

	local pod_impl = {}
	pod_impl.pod = pod
	pod_impl.anims = {}
	pod_impl.current_anim = nil
	pod_impl.cur_anim_name = ""
	pod_impl.anim_callback = nil
	pod_impl.click_callback = nil
	pod_impl.is_breaking_anim = false

	function pod_impl:get_node()
		return self.pod
	end

	function pod_impl:is_playing_anim()
		return (self.current_anim ~= nil)
	end

	function pod_impl:get_cur_anim_name()
		return self.cur_anim_name
	end

	function pod_impl:set_click_event(callback)
		self.click_callback = callback
		self.pod.on_click = function ()
			if self.click_callback ~= nil then
				self.click_callback(self)
			end
		end
	end

	function pod_impl:play_anim(anim_name, times, callback)
		return self:play_anim_detail(anim_name, times, 0, 1.0, callback)
	end
	
	function pod_impl:play_anim_detail(anim_name, times, delay, speed, callback)
		--[[if self.current_anim ~= nil and self.cur_anim_name == anim_name then
			return false
		end]]

		if times == nil then
			times = 1
		end
		if delay == nil then
			delay = 0
		end
		if speed == nil then
			speed = 1.0
		end

		local anim = nil
		for k,v in pairs(self.anims) do
			if k == anim_name then
				anim = v
				break
			end
		end

		if anim == nil then
			anim = self.pod:pod_anim():anim_name(anim_name)
			if anim ~= nil then
				self.anims[anim_name] = anim
			else
				return false
			end
		end

		if self.current_anim ~= nil then
			self.is_breaking_anim = true
			self.anim_callback = nil
			self.cur_anim_name = ""
			self.current_anim:stop()
			self.is_breaking_anim = false
		end

		self.current_anim = anim
		self.cur_anim_name = anim_name
		self.anim_repeat_count = times
		self.anim_callback = callback

		if times <= 0 then
			anim:repeat_count(-1):delay(delay):speed(speed):start()
		else
			anim:repeat_count(times):delay(delay):speed(speed):on_complete(function ()
				self.current_anim = nil
				self.cur_anim_name = ""
				if self.is_breaking_anim == false then
					if self.anim_callback ~= nil then
						self.anim_callback()
					end
				end
			end):start()
		end
		return true
	end

	function pod_impl:stop_anim()
		if self.current_anim ~= nil then
			self.is_breaking_anim = true
			self.anim_callback = nil
			self.current_anim:stop()
			self.is_breaking_anim = false
		end
		self.current_anim = nil
	end

	function pod_impl:set_visible(visible)
		self.pod:set_visible(visible)
	end

	function pod_impl:get_visible()
		return self.pod:get_visible()
	end

	return pod_impl
end