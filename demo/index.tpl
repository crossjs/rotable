<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-US-Compatible" content="IE=Edge">
<title>转盘</title>
<style>
.outer {
  float: left;
  margin-right: 10px;
  width: 596px;
}
.outer div {
  height: 586px;
  border: 5px solid #999;
  background: #eee;
}
object {
  display: block;
}
</style>
</head>
<body>
说明：js 与 swf 目录同级，下面分别存放对应的文件
<div class="outer">
  <button id="btnRoll1">Roll 1</button>
  <div id="flashContent1"></div>
</div>
<script src="../dist/js/@NAME-@VERSION.min.js"></script>
<script>
var rotable1 = new Rotable({
  containerId: 'flashContent1',
  // DEBUG，生产状态应为false或移除
  debug: true,
  flashvars: {
    // 获取所有奖项列表
    dataUrl: 'data.xml',
    // 获取校验码，不提供则说明无需校验码
    codeUrl: 'code.png',
    // 获取中奖信息
    luckUrl: 'luck.xml',
    // 提供给FLASH的回调函数，用于传递中奖信息
    callback: 'console.log'
  }
});
document.getElementById('btnRoll1').onclick = function () {
  rotable1.roll();
};
</script>
<script src="http://localhost:35729/livereload.js"></script>
</body>
</html>
