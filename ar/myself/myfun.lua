--POD旋转动画 函数
function anim_rota(node_name,_angle,_x,_y,_z ,_dur_time)
    local anim_id = node_name:rotate_by()
    :duration(_dur_time)
    :repeat_mode(1)
    :repeat_count(0)
    :axis_xyz(Vector3(_x,_y,_z))
    :to_degree(_angle)
    :on_complete(function()
        ARLOG('anim done')
    end)
    :start()
end
--无限旋转
function anim_rota_loop(node_name,_angle,_x,_y,_z,_dur_time)
    local anim_id = node_name:rotate_by()
    :duration(_dur_time)
    :repeat_mode(0)
    :repeat_count(-1)
    :axis_xyz(Vector3(_x,_y,_z))
    :to_degree(_angle)
    :start()
end

--POD缩放动画 函数
function anim_spfd(node_name,_vel,_dur_time,callback)
    anim_id = node_name:scale_by()
    :duration(_dur_time)
    :repeat_count(1)
    :to(Vector3(_vel,_vel,_vel))
    :on_complete(function()
        if callback~=nil then
            callback()
        end

    end)
    :start()
end
--POD缩放动画可调次数 函数
function anim_spfdCount(node_name,_vel,_count,_dur_time)
    anim_id = node_name:scale_by()
                       :duration(_dur_time)
                       :repeat_count(_count)
                       :repeat_mode (1)
                       :to(Vector3(_vel,_vel,_vel))
                       :on_complete(function()
                            ARLOG('zoro anim done')
                       end)
                       :start()
end
--plane平移动画
function anim_tran(node_name,_x,_y,_z ,_dur_time,callback)
    anim_id = node_name:move_by()
    :duration(_dur_time)
    :repeat_mode(1)
    :repeat_count(1)
    :to(Vector3(_x,_y,_z))
    :on_complete(function()
        if callback~=nil then
            callback()
        end
    end)
    :start()

end
--无线平移
function anim_tran_loop(node_name,_x,_y,_z ,_dur_time)
    anim_id = node_name:move_by()
    :duration(_dur_time)
    :repeat_mode(1)
    :repeat_count(4)
    :to(Vector3(_x,_y,_z))
    :on_complete(function()
        anim_tran_loop(node_name,_x,_y,_z ,_dur_time)
    end)
    :start()

end
--世界坐标转换成本地坐标
function worldToLocal(_pos,_rootpos)
    local _x = _pos.x - _rootpos.x
    local _y = _pos.y - _rootpos.y
    local _z = _pos.z - _rootpos.z
    local _vec =  Vector3(_x,_y,_z)
    return _vec
end
--获取符号
function getFH(_value)
    if(_value<0)then
        return -1
    end
    return 1
end
--获取节点坐标
function getNodePos(_node)
    local str = _node:get_world_position()
    local vec = StrToVector3(str)
    --ARLOG("32211::test getNodePos:x="..vec.x..",y="..vec.y..",z="..vec.z)
    return vec;
end
--获取节点旋转角度
function getNodeRota(_node)
    local str = _node:get_world_rotation()
    local vec = StrToVector3(str)
    --ARLOG(_str.."rotation=".."("..vec.x..","..vec.y..","..vec.z..")")
    return vec;
end
--获取节点缩放大小
function getNodeScale(_node)
    local str = _node:get_world_scale ()
    local vec = StrToVector3(str)
    --ARLOG("32211::test getNodePos:x="..vec.x..",y="..vec.y..",z="..vec.z)
    return vec;
end
--两个节点坐标差
function vecD_value(_node1,_node2)
    local v1 = getNodePos(_node1) local v2 = getNodePos(_node2)
    local _vec = Vector3(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z);
    return _vec
end
--两个节点坐标差
function vecNodeD_value(_vec,_node2)
    local v1 = _vec local v2 = getNodePos(_node2)
    local vec = Vector3(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z);
    return vec
end
--打印节点坐标
function showNodePos(_str,_node)
    local str = _node:get_world_position()
    local vec = StrToVector3(str)
    ARLOG(_str.."pos=".."("..vec.x..","..vec.y..","..vec.z..")")
end
--打印节点旋转角度
function showNodeRotation(_str,_node)
    local str = _node:get_world_rotation()
    local vec = StrToVector3(str)
    ARLOG(_str.."rotation=".."("..vec.x..","..vec.y..","..vec.z..")")
end
--打印节点缩放大小
function showNodeScale(_str,_node)
    local str = _node:get_world_scale()
    local vec = StrToVector3(str)
    ARLOG(_str.."NodeScale:x="..vec.x..",y="..vec.y..",z="..vec.z)
end
--节点碰撞判断
function collision(_node1,_node2,_vec)
    local str1 = _node1:get_world_position()
    local vec1 = StrToVector3(str1)
    local str2 = _node2:get_world_position()
    local vec2 = StrToVector3(str2)
    local bool1 = (math.abs(vec1.x-vec2.x)<_vec.x)
    local bool2 = (math.abs(vec1.y-vec2.y)<_vec.y)
    local bool3 = (math.abs(vec1.z-vec2.z)<_vec.z)
    --ARLOG("32211::collision->ball=>"..bool1..bool2..bool3);
    if(bool1 and bool2 and bool3)then
        return true
    end
    return false
end
--2D碰撞判断
function collision2D(_node1,_node2,_vec)
    local str1 = _node1:get_world_position()
    local vec1 = StrToVector3(str1)
    local str2 = _node2:get_world_position()
    local vec2 = StrToVector3(str2)
    local bool1 = (math.abs(vec1.x-vec2.x)<_vec.x)
    local bool2 = (math.abs(vec1.y-vec2.y)<_vec.y)
    local bool3 = (math.abs(vec1.z-vec2.z)<_vec.z)
    --ARLOG("32211::collision->ball=>"..bool1..bool2..bool3);
    if(bool1 and bool2 and bool3)then
        return true
    end
    return false
end
--坐标赋值移动
function translate(_nodeName,_vec3,_delta)
    _delta = 20
    local str = _nodeName:get_world_position()
    local vec = StrToVector3(str)
    _nodeName.position = Vector3(
            vec.x+(20*_vec3.x/_delta),vec.y+(20*_vec3.y/_delta),vec.z+(20*_vec3.z/_delta))
end
--归一
function guiy(_vec)
    local temp = math.sqrt(_vec.x*_vec.x+_vec.y*_vec.y)
    _vec.x=_vec.x/temp
    _vec.y=_vec.y/temp
    return _vec
end
--获取距离
function getDis(_vec)
    local temp = math.sqrt(_vec.x*_vec.x+_vec.y*_vec.y)
    return temp
end
--string转vector3
function StrToVector3(str)
    local number1 = string.find(str,',')
    local _x = string.sub(str,1,number1-1)

    str = string.sub(str,number1+1,string.len(str))
    local number2 = string.find(str,',')
    local _y = string.sub(str,1,number2-1)

    str = string.sub(str,number2+1,string.len(str))
    local _z = str

    _x = _x + 0
    _y = _y + 0
    _z = _z + 0

    local _vec = Vector3(_x,_y,_z)
    --_vec.x = _x
    --_vec.y = _y
    --_vec.z = _z
    return _vec
end
Time = 0
--计时器
function timeUpdate()
    AR:perform_after(50,function()
        if(updateTime)then
            Invincible()
            changeAirTime()
            Time = (Time+50)%1000000000
        end
        timeUpdate()
    end)
end
--呼吸灯
function huxiLight(_nodename,_maxintensity,_speed)
    local m_intensity = ((Time*_speed*_maxintensity)/1000)%_maxintensity*2
    local m_int = m_intensity
    if(m_intensity>_maxintensity)then
        m_int = _maxintensity*2 - m_intensity
    end
    _nodename:set_light_intensity(m_int)
end

function addNumber(a,b)
    return a+b
end
function selectNumber(count,array)
    local selected={}
    math.random(0,#array);
    math.randomseed(os.time());
    if(#array<=count)then return array end
    while #selected<count do
        math.random(#array);
        table.insert(selected,table.remove(array,math.random(#array)))
    end

    return selected;

end