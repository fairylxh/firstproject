app_controller = ae.ARApplicationController:shared_instance()
app_controller:require('./scripts/include.lua')
app_controller:require("./myself/myfun.lua")
app_controller:require('./helper/include.lua')
app = AR:create_application(AppType.Slam, 'bear')
app:load_scene_from_json('res/simple_scene.json','demo_scene')
scene = app:get_current_scene()

local t0=0
local t1=0
local timeDely=0;
local isBeforeShot=false
local isShoted=false

local BGM
local kaichangSound
local introLediSound
local taskIntroSound
local moveTipSound
local succesSound01
local succesSound02
local succesSound03
local watchWordSound
local overEndSound

local p_name = app:get_platform_name()
local screen_size = app:get_screen_size()
local MoveTip;
local CurrentModel;
local isModelShow=false;--模型是否已经显示
local LediLoopVideo;--startVideo后面的循环挥手视频
local LediSpeakVideo;
local arrowFrame;


local is_ledi_moving=false;--乐迪是否可以移动
local is_offscreen=false;--是否丢失
local enable_follow=false;--是否可以跟随
local is_start_game=false;--游戏是否开始
local is_collision=false;--是否碰撞
local gift_model={'GiftModel1','GiftModel2','GiftModel3' }
local collision_distance={250,250,250 }
local game_index=1
local ledi_offset=380
local gift_distance=920
local ledi=nil;
local complete_tip={'kuaidiTip', 'youxijiTip', 'huabanTip'}
local sound_tip
local ledi_show_not_start;

local is_phoneTip_click=false

--隐藏所有
function HideAll()
	scene.shadow:set_visible(false)
	scene.LediModel:set_visible(false)
	scene.GiftModel1:set_visible(false)--礼物1
	scene.GiftModel2:set_visible(false)--礼物2
	scene.GiftModel3:set_visible(false)--礼物3
	scene.StartVideo:set_visible(false)
	scene.LoadingVideo:set_visible(false)
	scene.EndVideo:set_visible(false)
	scene.JuheGroup:set_visible(false)
	scene.StartBtn:set_visible(false)
	scene.OnceMoreBtn:set_visible(false)
	scene.ReturnBtn:set_visible(false)
	scene.beSafeTip:set_visible(false)
	scene.PhoneTip:set_visible(false)

	scene.kuaidiTip:set_visible(false)
	scene.youxijiTip:set_visible(false)
	scene.huabanTip:set_visible(false)
	scene.arrowFrame:set_visible(false)

	scene.giftFlush:set_visible(false)
	scene.completeFlush:set_visible(false)
	scene.completeLOGO:set_visible(false)

	scene.PointMove:set_visible(false)
	scene.OffLine:set_visible(false)

	scene.resetPos:set_visible(false)
	scene.LOGO:set_visible(false)

end
--停止所有音乐（背景除外）
function StopAllSound()
	kaichangSound:stop()
	introLediSound:stop()
	taskIntroSound:stop()
	moveTipSound:stop()
	succesSound01:stop()
	succesSound02:stop()
	succesSound03:stop()
	watchWordSound:stop()
	overEndSound:stop()

	LediLoopVideo:stop()
	LediSpeakVideo:stop()
end
--复位
function ResetPostion()
	if ledi ~= nil then
		enable_follow = false
		scene.arrowFrame:set_visible(false)
		scene[gift_model[game_index]]:set_visible(false)
		reset_slam(function ()
			if is_start_game == true then
				enable_follow = true
				scene.arrowFrame:set_visible(true)
			end
			reset_ledi_and_gift()
		end)
	else
		app:relocate_current_scene()
		reset_slam_face_to_camera()
	end
end

function reset_slam(func)
	app.slam:slam_reset(0.5,0.5,1000)
	AR:perform_after(50, function()
		if func ~= nil then
			func()
		end
	end)
end



--聚合页按钮点击显示提示
function showBtnTip(seeOther)
	scene.seeOtherTip:set_visible(false)
	scene.forWaitTip:set_visible(false)
	local tip;
	if(seeOther)then
		tip=scene.seeOtherTip
	else
		tip=scene.forWaitTip
	end
	tip:set_visible(true)
	AR:perform_after(1000,function()
		tip:set_visible(false)
	end)
end

---分布加载》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》
app.on_loading_finish = function()
	ARLOG("pod: on_loaging_finish");
	scene:set_show_offscreen_guidance(false)
	--micOpen:start();
	scene.progressBar:set_visible(true)
	scene.on_batch_load_finish = function(id ,ret)
		ARLOG("pod: on_batch_load_finish");
		onBatchLoadFinish(id,ret)
	end
	scene.on_batch_load_progress_update = function(id, progress)
		--ARLOG("pod: on_batch_load_progress_update")
		onBatchLoadProgressUpdate(id,progress)
	end
	scene:load_batch(1)
end
BatchLoader.user_confirm_download = function(batch_id)
	if (batch_id == 'batch1') then
		scene:load_batch(1)
	end
end
BatchLoader.user_refuse_download = function(batch_id)
	-- io.write("user_refuse_download :"..batch_id)
end
function onBatchLoadFinish(id, ret)
	ARLOG("pod: onBatchLoadFinish");
	if (id == 1 and ret == -1) then
		BatchLoader.send_download_retry_msg()
		return
	end
	if (id == 1 and ret == 0) then
		batch_one_finish = true
		scene:delete_node_by_name("progressBar")
		run()--加载完成入口
	end
end
function onBatchLoadProgressUpdate(id, progress)
	--   io.write("onBatchLoadProgressUpdate ".. id .." "..progress)
	--ARLOG("pod: onBatchLoadProgressUpdate")
	if (id == 1) then
		updateprogress_1(progress)
	end
end
function updateprogress_1(progress)
	--ARLOG("pod: 加载进度"..tostring(progress))
	progress = math.ceil((progress+1)/10)
	-- 更新进度条
	--local delta = progress/202 * -1
	--progress_bar:set_material_vector_property("offsetRepeat", tostring(delta) ..",0, 1, 1")
	local pathProgress = "res/texture/floor/loading"..tostring(progress)..".png"
	scene.progressBar:replace_texture(pathProgress, "uDiffuseTexture")
end
---《《《《《《《《《《《《《《《《《《《《《《《《《《《《《《《《《分布加载

function run()
	--app.device:open_imu(0,0)
	dataInit()
	btnRegister()

	t0=os.clock()
	--ARLOG("pod: complete"..t0)
	--屏幕适配
	local size = screen_size.x/1080;
	scene.btnRoot.scale = Vector3(size,size,size);
	scene.GiftGroup.scale=Vector3(size,size,size);
	if p_name~="android" and size>0.75 then
		scene.resetRoot.scale=Vector3(size*0.85,size*0.85,size*0.85);
	else
		scene.resetRoot.scale=Vector3(size,size,size);
	end
	--隐藏
	HideAll()
	--初始化材质
	local body1=scene:get_node_by_name("LediModel_tui")
	body1:set_material_property("envMapIntensity",0.1);
	local body2=scene:get_node_by_name("LediModel_shoubi")
	body2:set_material_property("envMapIntensity",0.1);
	body2:set_material_property("metalness",0.01);
	local body3=scene:get_node_by_name("LediModel_jishen")
	body3:set_material_property("envMapIntensity",0.1);

	--开场视频
	AR:perform_after(300,function()
		--ARLOG("pod:开场视频播放")
		scene.LoadingVideo:set_visible(true)
		--播放开场音
		kaichangSound
		:on_complete(function()
			--播放背景音
			BGM:start()
		end)
		:start()
	end)

	scene.LoadingVideo:video()
	:repeat_count(1)
	:path("res/media/LoadingVideo.mp4")
	:on_complete(function()
		--ARLOG("pod: LoadingVideo complete")
		scene.LoadingVideo:video()
		:repeat_count(-1)
		:path("res/media/loadingLoop.mp4")
		:start()
		--出现聚合页
		scene.JuheGroup:set_visible(true)
		--播放按钮浮动动画
		anim_tran_loop(scene.Btn08,0,50,0,500)
		--播放点击提示动画
		scene.pointTip:framePicture()
		:repeat_count(-1)
		:start()
	end)
	:start()
end

function dataInit()
	BGM = scene.mainCamera:audio():path('/res/media/BGM.mp3'):repeat_count(9999999)
	kaichangSound=scene.directLight:audio():path("/res/media/kaichang.mp3"):repeat_count(1)
	introLediSound=scene.directLight:audio():path("/res/media/introLedi.mp3"):repeat_count(1)
	taskIntroSound=scene.directLight:audio():path("/res/media/task_intro.mp3"):repeat_count(1)
	moveTipSound=scene.directLight:audio():path("/res/media/move_tip.mp3"):repeat_count(1)
	succesSound01=scene.directLight:audio():path("/res/media/succes_first_tip.mp3"):repeat_count(1)
	succesSound02=scene.directLight:audio():path("/res/media/succes_second_tip.mp3"):repeat_count(1)
	succesSound03=scene.directLight:audio():path("/res/media/succes_all_tip.mp3"):repeat_count(1)
	watchWordSound=scene.directLight:audio():path("/res/media/watchword.mp3"):repeat_count(1)
	overEndSound=scene.directLight:audio():path("/res/media/over_end.mp3"):repeat_count(1)

	sound_tip={succesSound01,succesSound02,succesSound03}
	--循环视频
	LediLoopVideo = scene.StartVideo:video():path("/res/media/LediLoop.mp4"):repeat_count(-1)
	LediSpeakVideo=scene.StartVideo:video():path("/res/media/LediSpeak.mp4"):repeat_count(-1)

	arrowFrame=scene.arrowFrame:framePicture():repeat_count(-1)

	ledi_show_not_start=false;
end

function btnRegister()
	scene.Btn01.on_click=function()
		--Alert():show_toast("请扫描其他卡纸解锁游戏")
		showBtnTip(true)
	end
	scene.Btn02.on_click=function()
		--Alert():show_toast("请扫描其他卡纸解锁游戏")
		showBtnTip(true)
	end
	scene.Btn03.on_click=function()
		--Alert():show_toast("请扫描其他卡纸解锁游戏")
		showBtnTip(true)
	end
	scene.Btn04.on_click=function()
		--Alert():show_toast("敬请期待")
		showBtnTip(true)
	end
	scene.Btn05.on_click=function()
		--Alert():show_toast("请扫描其他卡纸解锁游戏")
		showBtnTip(true)
	end
	scene.Btn06.on_click=function()
		--Alert():show_toast("敬请期待")
		showBtnTip(true)
	end
	scene.Btn07.on_click= function()
        --Alert():show_toast("请扫描其他卡纸解锁游戏")
        showBtnTip(true)
    end
    --快递按钮
	scene.Btn08.on_click=function()
        HideAll()
        StopAllSound()
		ShowStartView()
	end

	--开始按钮
	scene.StartBtn.on_click=function()
		ARLOG("pod: startbtn down")
		HideAll()
		StopAllSound()
		--出现乐迪和礼物1
		--出现放置提示
		scene.PhoneTip:set_visible(true)

        AR:perform_after(3000,function()
            if is_phoneTip_click==false then
                scene.PhoneTip:set_visible(false)
                show_ledi_start()
                is_phoneTip_click=true
            end

        end)

	end
	--放置
	scene.PhoneTip.on_click=function()
        is_phoneTip_click=true
		scene.PhoneTip:set_visible(false)
		show_ledi_start()
	end
	--再来一次
	scene.OnceMoreBtn.on_click=function()
		--ARLOG("pod: 再来一次")
		HideAll()
		StopAllSound()
		ShowStartView()
	end
	--返回
	scene.ReturnBtn.on_click=function()
		ARLOG("pod: 更多游戏")
		HideAll()
		StopAllSound()
		--显示

		isBeforeShot=false


		--跳转链接
		app:open_url('https://qingmingar.ews.m.jaeapp.com/Ledi/index.html')
	end

	--复位键
	scene.resetPos.on_click=function()
		ResetPostion()
	end
	--模型复位
	scene.OffLine.on_click=function()
		ARLOG("pod: OffLine.on_click")
		ResetPostion()
	end

	--测试
	scene.GiftModel2.on_click=function()
		scene.GiftModel2:set_visible(false)
	end
end
--点击开始或者再来一次后，显示开始页面
function ShowStartView()
	isBeforeShot=false

	enable_follow = false
	is_offscreen = false
	is_collision = false
	scene:set_show_offscreen_guidance(false)
	--播放乐迪开场动画
	AR:perform_after(300,function()
		scene.StartVideo:set_visible(true)
		scene.LOGO:set_visible(true)
		--播放乐迪开场音效
		introLediSound:start()
	end)
	ARLOG("pod: 乐迪进场")
	scene.StartVideo:video()
	:repeat_count(1)
	:path("res/media/LediStart.mp4")
	:on_complete(function()
		--ARLOG("pod: VideoComplete")
		scene.StartVideo:video()
		:repeat_count(1)
		:path("res/media/LediChange.mp4")
		:on_complete(function()
			--播放乐迪说话动画
			LediSpeakVideo:start()
			taskIntroSound:
			on_complete(function()
				scene.StartVideo:stop()
				LediSpeakVideo:stop()
				LediLoopVideo:start()
				--出现开始按钮
				scene.StartBtn:set_visible(true)
				ARLOG("pod: 开始按钮")
			end)
			:start()
		end)
		:start()
	end)
	:start()
end
--乐迪和礼物1出现
function show_ledi_start()
	reset_slam()

	scene.GiftModel1:set_visible(true)

	--scene.root:reset_rts()
	--设置第一个礼物
	game_index=1
	is_start_game=false
	scene.LediModel:set_visible(true)
	scene.shadow:set_visible(true)
	ledi=FQPod:create(scene.LediModel)
	--放置位置
	--ledi:get_node().position = Vector3(0,-380,0)
	--ledi:get_node():set_rotation_by_xyz(90,180,0)
	ledi_show_not_start=true;
	reset_ledi_and_gift()
	ledi:play_anim("daiji",-1)
	scene:set_offscreen_guidance_target("LediModel")
	scene:set_show_offscreen_guidance(true)


	--scene["OffLine"]:set_visible(true)
	moveTipSound:
	on_complete(function()
		lediStartMove()
	end)
	:start()
end
--乐迪开始移动
function lediStartMove()
	for i = 1, #complete_tip do
		scene[complete_tip[i]]:set_visible(false)
	end

	--scene.beSafeTip:set_visible(true)
	ARLOG("pod: 安全提示出现")
	--scene.sky:set_visible(true)
	--scene.walkTip:set_visible(true)
	scene.arrowFrame:set_visible(true)
	arrowFrame:start()
	AR:perform_after(2500, function ()
		scene.beSafeTip:set_visible(false)
		--显示复位按钮
		scene.resetPos:set_visible(true)
		--测试缩放
		--scene.resetRoot.scale=Vector3(0.5,0.5,0.5)
		--arrowVideo:start()
		ARLOG("pod: 安全提示隐藏，乐迪开始移动")
		--reset_slam()
		ledi:play_anim_detail("walk", -1, 0, 1)
		--reset_ledi_and_gift()
		ledi_show_not_start=false
		enable_follow = true
		is_offscreen = false
		is_collision = false
		is_start_game = true
	end)
end
--乐迪和礼物重定位
function reset_ledi_and_gift()
	scene[gift_model[game_index]]:set_visible(true)

	local camera_dir = FQUtils:get_slam_camera_dir()
	local camera_pos = scene.mainCamera.position
	camera_dir.z=0;
	camera_pos.z=0
	--ARLOG("pod: 摄像机的direction:"..camera_dir.x.."--"..camera_dir.y.."--"..camera_dir.z)
	--ARLOG("pod: 摄像机的position:"..camera_pos.x.."--"..camera_pos.y.."--"..camera_pos.z)
	ledi:get_node().position = camera_pos + camera_dir * ledi_offset
	scene[gift_model[game_index]].position = camera_pos + camera_dir * gift_distance+Vector3(0,0,0)
	--ARLOG("pod: 乐迪的position:"..scene.LediModel.position.x.."--"..scene.LediModel.position.y.."--"..scene.LediModel.position.z)
	--ARLOG("pod: 礼物的position:"..scene[gift_model[game_index]].position.x.."--"..scene[gift_model[game_index]].position.y.."--"..scene[gift_model[game_index]].position.z)
	scene.arrowFrame.position=ledi:get_node().position+camera_dir*200+Vector3(0,1,0)
	--角度
	local angle=FQMath:vector_angle(-camera_dir, Vector3(0,1,0))
	ledi:get_node():set_rotation_by_xyz(90, 180+angle, 0)
	if game_index == 3 then
		scene[gift_model[game_index]]:set_rotation_by_xyz(90, 180 + angle, 0)
	else
		scene[gift_model[game_index]]:set_rotation_by_xyz(90, 180 + angle, 0)
	end
	scene.arrowFrame:set_rotation_by_xyz(90,180+angle,0)
	scene:set_offscreen_guidance_target(gift_model[game_index])
	scene:set_show_offscreen_guidance(true)
end



--监听模型显示和丢失
--模型出现
app.offscreen_button_hide = function()
	scene.OffLine:set_visible(false)
	is_offscreen = false
end
--模型丢失
app.offscreen_button_show = function()
	scene.OffLine:set_visible(true)
	scene.OffLine:framePicture()
	:repeat_count(-1)
	:start()
	is_offscreen = true
end







function TimeDely()
	t1 = os.clock();
	timeDely = t1 - t0;
	t0 = t1;
end
scene.mainCamera.on_update=function(_delta)
	--ARLOG("pod: 间隔"..timeDely)
	--TimeDely()
    --if(p_name =="android")then
    --    if(timeDely>0.3)and(isBeforeShot)then
	--		ShowEndVideo()
    --    end
    --else
    --    if(timeDely>0.1)and(isBeforeShot)then
	--		ShowEndVideo()
    --    end
    --end
	lediMoveUpdate()
	lediUpdate()
end

function lediMoveUpdate()
	if ledi_show_not_start then
		reset_ledi_and_gift()
	end

	if enable_follow == false or is_offscreen == true or is_collision == true then return end
	---local posY = tonumber(scene.mainCamera.position.y) + dino_offset
	--dino:get_node().position = Vector3(0, posY ,0)
	local camera_dir = FQUtils:get_slam_camera_dir()
	local camera_pos = scene.mainCamera.position
	camera_dir.z = 0
	camera_pos.z = 0
	ledi:get_node().position = camera_pos + camera_dir * ledi_offset
	check_ledi_collision(scene[gift_model[game_index]])
end
--乐迪与礼盒碰撞检测
function check_ledi_collision(node)
	local pos1 = ledi:get_node().position
	local pos2 = node.position
	local distance = FQMath:vector_distance(pos1, pos2)
	local collision_distance = collision_distance[game_index]
	if distance < collision_distance then
		follow_collision()
	end
end
--碰撞后
function follow_collision()
	is_collision = true
	enable_follow = false
	--
	scene.resetPos:set_touchable(false)
	ARLOG("pod: 碰到了第"..game_index.."个")
	--scene.sky:set_visible(false)
	scene.arrowFrame:set_visible(false)
	scene[gift_model[game_index]]:set_visible(false)
	--出现礼物tip。光圈
	scene[complete_tip[game_index]]:set_visible(true)
	scene.giftFlush:set_visible(true)
	anim_rota_loop(scene.giftFlush,360,0,1,0,4000)
	anim_tran_loop(scene[complete_tip[game_index]],0,50,0,500)
	ARLOG("pod: 第"..game_index.."个碰撞,显示提示:")
	ledi:stop_anim()
	ledi:play_anim_detail("zhuanshen",1,0,0.6,function()
		ledi:play_anim("daiji",-1)
	end)
	if game_index == 2 then
		--cage_open()
	end
	--播放取得语音
	sound_tip[game_index]:
	on_complete(function()
		AR:perform_after(500, function ()
			scene[complete_tip[game_index]]:set_visible(false)
			scene[gift_model[game_index]]:set_visible(false)
			scene.giftFlush:set_visible(false)
			if game_index < #complete_tip then
				game_index = game_index + 1
				next_level()
			else
				ledi:set_visible(false)
				ledi:stop_anim()
				scene.arrowFrame:set_visible(false)
				scene.completeLOGO:set_visible(true)
				scene.completeLOGO.scale=Vector3(1,1,1)
				--放大LOGO
				scene.completeLOGO:scale_by()
					:duration(500)
					:repeat_count(1)
					:to(Vector3(1862,1,418))
					:on_complete(function()
						ARLOG("pod:答完了...")
						scene.completeLOGO.scale=Vector3(1862,1,418)
						scene.completeFlush:set_visible(true)
						anim_rota_loop(scene.completeFlush,360,0,1,0,4000)
						watchWordSound:
						on_complete(function()
							AR:perform_after(1000,function()
								all_complete()
							end)
						end)
						:start()
					end)
					:start()
				return
			end
			ledi:play_anim_detail("walk",-1,0,1)
		end)
	end)
	:start()
end
--下一个
function next_level()
	reset_slam(function ()
		ledi:set_visible(true)
		scene.arrowFrame:set_visible(true)
		reset_ledi_and_gift()
		if game_index == 2 then

		end

		AR:perform_after(100, function ()
			enable_follow = true
			is_offscreen = false
			is_collision = false
			scene.resetPos:set_touchable(true)
		end)

	end)

	if game_index == 3 then

	end
end
--全部结束
function all_complete()
	enable_follow = false
	is_offscreen = false
	is_collision = false
	app.slam:slam_reset(0.5,0.6,1000)
	ShowEndVideo()
end
--播放结束动画
function ShowEndVideo()
	HideAll()
	StopAllSound()
	scene.OnceMoreBtn:set_visible(true)
	scene.ReturnBtn:set_visible(true)
	scene.EndVideo:set_visible(true)
	scene.LOGO:set_visible(true)
	scene.EndVideo:video()
	:repeat_count(-1)
	:path("res/media/endVideo.mp4")
	:start()
	--播放结束loading语音
	overEndSound:start()
end

--重置scene.root面向摄像机
function reset_slam_face_to_camera(func)
	--scene.root:reset_rts()
	app.slam:slam_reset(0.5,0.6,1000)
	scene.root:reset_rts()
	AR:perform_after(50, function()
		local pos1 = scene.root.position
		local pos2 = scene.mainCamera.position
		local scene_dir = pos1 - pos2
		scene_dir.z = 0
		scene_dir = FQMath:vector_normal(scene_dir)
		local angle = FQMath:vector_angle(scene_dir, Vector3(0,1,0))
		scene.root:set_rotation_by_xyz(0, 0, angle)
		if func ~= nil then
			func()
		end
	end)
end