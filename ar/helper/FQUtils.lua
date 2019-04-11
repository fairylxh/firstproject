
FQUtils = {}

-- 获取标准的Time Delta值（按30帧/秒计算）
function FQUtils:get_standard_dt()
    return 0.034
end

-- 获取当前时间
function FQUtils:get_time()
    local t = os.clock()
    if app:get_platform_name() ~= "android" then
        t = t * 1.8
    end
    return t
end

-- 获取场景根节点的缩放值
function FQUtils:get_scene_root_scale(scene)
	local root_node = scene:get_root_node()
	local scale_str = root_node:get_scale()
	local scalexyz = self:split_str(scale_str,',')
	local scale = Vector3(tonumber(scalexyz[1]), tonumber(scalexyz[2]), tonumber(scalexyz[3]))
	return scale
end

-- 设置场景根节点的缩放值
function FQUtils:set_scene_root_scale(scene, scale)
	local root_node = scene:get_root_node()
	root_node:set_scale(scale.x, scale.y, scale.z)
end

-- 拆分字符串
function FQUtils:split_str(input, delimiter)
	input = tostring(input)  
    delimiter = tostring(delimiter)  
    if (delimiter=='') then return false end  
    local pos,arr = 0, {}  
    -- for each divider found  
    for st,sp in function() return string.find(input, delimiter, pos, true) end do  
        table.insert(arr, string.sub(input, pos, st - 1))  
        pos = sp + 1
    end  
    table.insert(arr, string.sub(input, pos))  
    return arr  
end

-- 开启手势识别
function FQUtils:open_paddle_gesture(precision, on_discern_gesture)

    if precision > 1 then
        precision = 1
    elseif precision < 0 then
        precision = 0
    end

    resultType1 = 0
    resultType2 = 0
    resultType3 = 0

    PaddleGesture:send_control_msg(1)

    local validateResult = function (resultType)
        resultType1 = resultType2
        resultType2 = resultType3
        resultType3 = resultType
        if(resultType1 == resultType2  and resultType2 == resultType3) then
            return resultType
        end
        return 0
    end

    PaddleGesture.on_gesture_detected = function(mapData)
        local count = mapData['gesture_count']
        resultMap = mapData['gesture_result1']
        result = resultMap['type']
        score = resultMap['score']

        x1 = resultMap['x1']
        y1 = resultMap['y1']
        x2 = resultMap['x2']
        y2 = resultMap['y2']

        result = validateResult(result)
        if (score <= precision) then
            return
        end

        if on_discern_gesture ~= nil then
            on_discern_gesture(result)
        end
    end
end

-- 创建序列帧动画
function FQUtils:create_frame_anim(node, format, from, to)
    local frames = {}
    for i=from,to do
        local path = string.format("/res/texture/"..format, i)
        frames[#frames+1] = path
    end
    local anim = FQFrameAnim:create(node, frames)
    return anim
end

function FQUtils:get_slam_camera_dir()
    local camera_dir = Vector3(0,1,0)
    local rotate = Vector3(scene.mainCamera:get_world_rotation())
    camera_dir = FQMath:vector_rotate(camera_dir, rotate.z, FQMath.z_axis)
    camera_dir = FQMath:vector_normal(camera_dir)
    return camera_dir
end