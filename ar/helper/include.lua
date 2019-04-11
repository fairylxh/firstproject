-- 不要修改模块的引入顺序 --
-- 模块引入的路径以default.lua 所在路径为根目录 --
app_controller:require('./helper/FQUtils.lua')
app_controller:require('./helper/FQMath.lua')
app_controller:require('./helper/FQUpdater.lua')
app_controller:require('./helper/FQTimer.lua')
app_controller:require('./helper/FQPod.lua')
app_controller:require('./helper/FQFrameAnim.lua')
app_controller:require('./helper/FQAudioPlayer.lua')


app_controller:require('./helper/tween/FQTween.lua')
app_controller:require('./helper/tween/FQAction.lua')
app_controller:require('./helper/tween/FQSequence.lua')
app_controller:require('./helper/tween/FQSpawn.lua')
app_controller:require('./helper/tween/FQRepeat.lua')
app_controller:require('./helper/tween/FQCallback.lua')
app_controller:require('./helper/tween/FQMove.lua')
app_controller:require('./helper/tween/FQJump.lua')
app_controller:require('./helper/tween/FQDelay.lua')
app_controller:require('./helper/tween/FQScale.lua')
app_controller:require('./helper/tween/FQRotate.lua')
