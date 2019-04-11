
FQAudioPlayer = {}
FQAudioPlayer.audio_list = {}
FQAudioPlayer.break_list = {}
FQAudioPlayer.is_playing_music = false


function FQAudioPlayer:play_music(audio_name)
	local delay = 0
	if self.is_playing_music == true then
		app:stop_bg_music()
		delay = 200
	end
	app:play_bg_music("/res/media/"..audio_name, -1, delay)
	self.is_playing_music = true
end

function FQAudioPlayer:stop_music()
	app:stop_bg_music()
	self.is_playing_music = false
end

----- 播放音效 -----
function FQAudioPlayer:play_sound(node, audio_name, count, callback)
	if node == nil then
		return
	end
	if count == nil then
		count = 1
	end

	local audio_data = nil
	for k, v in pairs(self.audio_list) do
		if v.node == node then
			audio_data = v
			break
		end
	end

	if audio_data == nil then
		audio_data = {}
		audio_data.node = node
		audio_data.audio_name = audio_name
		audio_data.audio = nil
		audio_data.callback = nil
		audio_data.is_breaking = false
		audio_data.break_wait_frame = 0
		table.insert(self.audio_list, audio_data)
		FQUpdater:register(node, audio_data)

		function audio_data:update()
			if self.break_wait_frame > 0 then
				self.is_breaking = false
				return
			end 
			self.break_wait_frame = self.break_wait_frame + 1
		end
	else
		if audio_data.audio ~= nil then
			audio_data.is_breaking = true
			audio_data.break_wait_frame = 0
			audio_data.audio:stop()
		end
	end
	audio_data.callback = callback

	if callback == nil then
		audio_data.audio = node:audio():path("./res/media/"..audio_name):repeat_count(count):start()
	else
		audio_data.audio = node:audio():path("./res/media/"..audio_name):repeat_count(count):on_complete(function ()
			if audio_data.is_breaking == false then
				audio_data.audio = nil
				if audio_data.callback ~= nil then
					audio_data.callback()
				end
			end
		end):start()
	end
end

----- 停止 -----
function FQAudioPlayer:stop_by_node(node)
	if node == nil then
		return
	end

	for k, v in pairs(self.audio_list) do
		if v.node == node then
			v.is_breaking = true
			v.break_wait_frame = 0
			v.callback = nil
			if v.audio ~= nil then
				v.audio:stop()
			end
			break
		end
	end
end

function FQAudioPlayer:stop_by_name(audio_name)
	for k, v in pairs(self.audio_list) do
		if v.audio_name == audio_name then
			v.is_breaking = true
			v.break_wait_frame = 0
			v.callback = nil
			if v.audio ~= nil then
				v.audio:stop()
			end
		end
	end
end

function FQAudioPlayer:stop_sounds()
	for k, v in pairs(self.audio_list) do
		if v.audio ~= nil then
			v.is_breaking = true
			v.break_wait_frame = 0
			v.callback = nil
			v.audio:stop()
		end
	end
end


----- 暂停 -----
function FQAudioPlayer:pause_by_node(node)
	if node == nil then
		return
	end

	for k, v in pairs(self.audio_list) do
		if v.node == node and v.audio ~= nil then
			v.audio:pause()
			break
		end
	end
end

function FQAudioPlayer:pause_by_name(audio_name)
	for k, v in pairs(self.audio_list) do
		if v.audio_name == audio_name and v.audio ~= nil then
			v.audio:pause()
		end
	end
end

function FQAudioPlayer:pause_sounds()
	for k, v in pairs(self.audio_list) do
		if v.audio ~= nil then
			v.audio:pause()
		end
	end
end


----- 恢复 -----
function FQAudioPlayer:resume_by_node(node)
	if node == nil then
		return
	end

	for k, v in pairs(self.audio_list) do
		if v.node == node and v.audio ~= nil then
			v.audio:resume()
			break
		end
	end
end

function FQAudioPlayer:resume_by_name(audio_name)
	for k, v in pairs(self.audio_list) do
		if v.audio_name == audio_name and v.audio ~= nil then
			v.audio:resume()
		end
	end
end

function FQAudioPlayer:resume_sounds()
	for k, v in pairs(self.audio_list) do
		if v.audio ~= nil then
			v.audio:resume()
		end
	end
end