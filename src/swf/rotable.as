package  {

  import flash.display.Stage;
  import flash.display.StageScaleMode;
  import flash.display.StageAlign;
  import flash.display.Loader;
  import flash.display.LoaderInfo;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.events.FocusEvent;
  import flash.net.URLRequest;
  import flash.net.URLLoader;
  import flash.external.ExternalInterface;
  // import flash.system.Capabilities;
  // import flash.system.Security;
  import flash.utils.setTimeout;
  import fl.transitions.Tween;
  import fl.transitions.TweenEvent;
  import fl.transitions.easing.Strong;
  import fl.transitions.easing.None;

  public class rotable extends Sprite {
    private var rLoad:MovieClip;
    private var rRoll:MovieClip;
    private var rCode:MovieClip;

    private var rRollItv:Tween;
    private var rLoadItv:Tween;

    private var DEBUG:Boolean;

    private var dataUrl:String = '';
    private var codeUrl:String = '';
    private var luckUrl:String = '';
    private var callback:String = '';

    // 校验码输入框placeholder
    private var placeholder:String = '请输入校验码';
    // 转动频率
    private var rollDelay:int = 20;
    // 收到中奖信息，延迟
    private var bingoDelay:int = 5000;
    // 奖项数量
    private var pieNum:int = 0;
    // 角度
    private var pieArc:Number = 0;

    // 已加载的数量
    private var loadedNum:int = 0;

    // 中奖信息
    private var luckData:Object = {};

    private var centerX:Number = 0;
    private var centerY:Number = 0;
    private var radiusX:Number;
    private var radiusY:Number;

    private var bgColors:Array = [0xfffdef, 0xfff3cc];

    private var picIDs:Array = [];

    public function rotable() {
      // constructor code

      var flashvars:Object = LoaderInfo( this.root.loaderInfo ).parameters;

      DEBUG = flashvars.debug === '1';

      dataUrl = flashvars.dataUrl;
      codeUrl = flashvars.codeUrl;
      luckUrl = flashvars.luckUrl;

      callback = flashvars.callback;

      if (typeof(flashvars.rollDelay) !== 'undefined'
          && !isNaN(flashvars.rollDelay))
        rollDelay = parseInt(flashvars.rollDelay, 10);

      if (typeof(flashvars.bingoDelay) !== 'undefined'
          && !isNaN(flashvars.bingoDelay))
        bingoDelay = parseInt(flashvars.bingoDelay, 10);

      // if (ExternalInterface.available){
        ExternalInterface.addCallback('roll', _roll);
      // }

      init();
    }

    private function init():void {
      DEBUG && ExternalInterface.call(callback, 'init');

      initStage();
    }

    private function initStage():void {
      DEBUG && ExternalInterface.call(callback, 'initStage');

      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;

      var sw:Number = stage.stageWidth,
        sh:Number = stage.stageHeight;

      DEBUG && ExternalInterface.call(callback, sw + ' - ' + sh);

      if (sw === 0 || sh === 0) {
        setTimeout(initStage, 10);
        return void;
      }

      centerX = sw / 2;
      centerY = sh / 2;

      // 暂时不支持椭圆形
      // radiusX = centerX - 1;
      // radiusY = centerY - 1;

      radiusY = radiusX = Math.min(centerX, centerY) - 1;

      initLoad();

      initRoll();

      initCode();

      loadData();

    }

    private function initLoad():void {
      DEBUG && ExternalInterface.call(callback, 'initLoad');
      rLoad = new RLoad();
      addChildAt(rLoad, 0);
      rLoad.x = centerX;
      rLoad.y = centerY;
    }

    private function initRoll():void {
      DEBUG && ExternalInterface.call(callback, 'initRoll');
      rRoll = new RRoll();
      addChildAt(rRoll, 1);
      rRoll.x = centerX;
      rRoll.y = centerY;

      // 隐藏按钮
      rRoll.visible = false;

      rRoll.btn.addEventListener(MouseEvent.CLICK, roll);
    }

    private function initCode():void {
      DEBUG && ExternalInterface.call(callback, 'initCode');
      rCode = new RCode();
      addChildAt(rCode, 2);
      rCode.x = centerX;
      rCode.y = centerY;

      // 隐藏验证码
      rCode.visible = false;

      if (codeUrl !== '') {
        rCode.btnReload.addEventListener(MouseEvent.CLICK, loadCode);
        rCode.txt.addEventListener(FocusEvent.FOCUS_IN, focus);
        rCode.btnSubmit.addEventListener(MouseEvent.CLICK, checkCode);
      }
    }

    private function startLoading():void {
      DEBUG && ExternalInterface.call(callback, 'startLoading');

      function tween () {
        rLoadItv = new Tween(rLoad.arr, 'rotation', None.easeNone, -180, 180, .5, true);
        rRollItv.looping = true;
      }

      function finish (event:TweenEvent) {
      }

      tween();
      rLoadItv.addEventListener(TweenEvent.MOTION_FINISH, finish);
    }

    private function stopLoading():void {
      DEBUG && ExternalInterface.call(callback, 'stopLoading');
      rLoadItv.stop();
      rLoad.visible = false;
      rRoll.visible = true;
    }

    // 画饼图
    private function drawPie(mc:MovieClip, x:Number, y:Number, startAngle:Number, arc:Number, radiusX:Number, radiusY:Number):void {
      //DEBUG && ExternalInterface.call('console.log', 'drawPie');
      // move to x,y position
      mc.graphics.moveTo(x,y);
      // Init vars
      var segAngle, theta, angle, angleMid, segs, ax, ay, bx, by, cx, cy;
      // limit sweep to reasonable numbers
      if (Math.abs(arc) > 360) {
        arc = 360;
      }
      // Flash uses 8 segments per circle, to match that, we draw in a maximum
      // of 45 degree segments. First we calculate how many segments are needed
      // for our arc.
      segs = Math.ceil(Math.abs(arc) / 45);
      // Now calculate the sweep of each segment.
      segAngle = arc / segs;
      // The math requires radians rather than degrees. To convert from degrees
      // use the formula (degrees/180)*Math.PI to get radians.
      theta = -(segAngle / 180) * Math.PI;
      // convert angle startAngle to radians
      angle = -(startAngle / 180) * Math.PI;
      // draw the curve in segments no larger than 45 degrees.
      if (segs > 0) {
        // DEBUG && ExternalInterface.call(callback, 'XY', theta, angle);
        // draw a line from the center to the start of the curve
        ax = x + Math.cos(startAngle / 180 * Math.PI) * radiusX;
        ay = y + Math.sin(-startAngle / 180 * Math.PI) * radiusY;
        mc.graphics.lineTo(ax, ay);
        // Loop for drawing curve segments
        for (var i = 0; i < segs; i++) {
          angle += theta;
          angleMid = angle - (theta / 2);
          bx = x + Math.cos(angle) * radiusX;
          by = y + Math.sin(angle) * radiusY;
          cx = x + Math.cos(angleMid) * (radiusX / Math.cos(theta / 2));
          cy = y + Math.sin(angleMid) * (radiusY / Math.cos(theta / 2));
          mc.graphics.curveTo(cx, cy, bx, by);
        }
        // close the wedge by drawing a line to the center
        mc.graphics.lineTo(x, y);
      }
    }

    // 加载奖品图片
    private function loadPic(mc:MovieClip, pic:String, x:Number, y:Number):void {
      //DEBUG && ExternalInterface.call('console.log', 'loadPic');

      var mcPic:MovieClip = new MovieClip();
      mc.addChild(mcPic);
      mcPic.x = x;
      mcPic.y = y;

      function picLoaded (event:Event):void {
        mcPic.addChild(mcLoader);

        mcPic.x -= mcPic.width * .5;
        mcPic.y -= mcPic.height * .5;
        if (++loadedNum === pieNum) {
          // 显示按钮
          rRoll.visible = true;

          // 启用按钮
          // rRoll.btn.enabled = true;
          stopLoading();
        }
      }

      var mcLoader = new Loader();
      mcLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, picLoaded);
      mcLoader.load(new URLRequest(pic));
    }

    // 获取奖项信息
    private function loadData():void {
      DEBUG && ExternalInterface.call('console.log', 'loadData');

      function loadComplete(event:Event):void {
        var pics:XMLList, i:int,
          mc:MovieClip, sa:Number, sa2:Number,
          rx:Number, ry:Number, x:Number, y:Number,
          colorsLength:int = bgColors.length;

        dataXml.ignoreWhitespace = true;
        dataXml = XML(dataLoader.data),

        pics = dataXml.children();

        DEBUG && ExternalInterface.call('console.log', 'Data loaded.');

        pieNum = pics.length();
        // for (pic in pi)

        // 画扇形
        for (i = 0, pieArc = -360 / pieNum; i < pieNum; i++) {
          picIDs.push(pics[i].attribute('id').toXMLString());

          mc = new MovieClip();
          rRoll.pie.addChild(mc);

          mc.graphics.beginFill(bgColors[i % colorsLength], 100);

          sa = 90 + pieArc * i;
          sa2 = 90 + pieArc * (i + .5);

          drawPie(mc, 0, 0, sa, pieArc, radiusX, radiusY);

          rx = radiusX * .66 / Math.cos(pieArc / 360 * Math.PI);
          ry = radiusY * .66 / Math.cos(pieArc / 360 * Math.PI);
          x = (sa2 === 90 || sa2 === 270) ? 0 : rx * Math.cos(sa2 / 180 * Math.PI);
          y = (sa2 === 180 || sa2 === 360) ? 0 : -ry * Math.sin(sa2 / 180 * Math.PI);

          loadPic(mc, pics[i].attribute('src').toXMLString(), x, y);
        }
      }

      var dataXml:XML = new XML(),
        dataRequest:URLRequest = new URLRequest(addrnd(dataUrl)),
        dataLoader:URLLoader = new URLLoader(dataRequest);
      dataLoader.addEventListener('complete', loadComplete);

      startLoading();
    }

    // 获取中奖信息
    private function loadLuck():void {
      DEBUG && ExternalInterface.call('console.log', 'loadLuck');

      function loadComplete(event:Event):void {
        DEBUG && ExternalInterface.call('console.log', 'loadLuck, loaded.');
        luckXml.ignoreWhitespace = true;
        luckXml = XML(luckLoader.data);
        var i:int, n:int, atts:XMLList = luckXml.attributes();
        luckData = {};
        for (i = 0, n = atts.length(); i < n; i++) {
          luckData[atts[i].name().localName] = atts[i].toXMLString();
        }
        // 5秒之后再显示中奖信息
        setTimeout(function() {
          bingo();
        }, bingoDelay);
      }

      var luckXml:XML = new XML(),
        luckRequest:URLRequest = new URLRequest(codeUrl ? addpar(addrnd(luckUrl), 'vcode', rCode.txt.text) : addrnd(luckUrl)),
        luckLoader:URLLoader = new URLLoader(luckRequest);
      luckLoader.addEventListener('complete', loadComplete);

      if (codeUrl !== '') {
        DEBUG && ExternalInterface.call(callback, rCode.txt.text);

        rCode.visible = false;
        rCode.txt.text = placeholder;
      }
    }

    private function bingo():void {
      DEBUG && ExternalInterface.call(callback, 'bingo');

      var n = picIDs.indexOf(luckData.id),
        b = rRoll.arr.rotation,
        r = n === -1 ? 0 : (-pieArc * n - pieArc/ 2);

      function tween () {
        rRollItv = new Tween(rRoll.arr, 'rotation', Strong.easeOut, b, r, .5, true);
      }

      function finish (event:TweenEvent) {
        bonus();
      }

      if (rRollItv.isPlaying) {
        rRollItv.stop();
      }

      tween();

      rRollItv.addEventListener(TweenEvent.MOTION_FINISH, finish);
    }

    private function bonus():void {
      rRoll.btn.enabled = true;
      rRoll.btn.mouseEnabled = true;
      ExternalInterface.call(callback, luckData);
    }

    private function loadCode(event:MouseEvent):void {
      DEBUG && ExternalInterface.call(callback, 'loadCode');

      function loadComplete (event:Event):void {
        rCode.visible = true;
        rCode.img.addChild(mcLoader);
      }

      var mcLoader = new Loader();
      mcLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
      mcLoader.load(new URLRequest(addrnd(codeUrl)));
    }

    private function checkCode(event:MouseEvent):void {
      DEBUG && ExternalInterface.call(callback, 'checkCode');
      if (rCode.txt.text === placeholder) {
        // nothing todo
      } else if (rCode.txt.text === '') {
        rCode.txt.text = placeholder;
      } else {
        loadLuck();
      }
    }

    private function focus(event:FocusEvent):void {
      if (rCode.txt.text === placeholder) {
        rCode.txt.text = '';
      }
    }

    private function roll(event:MouseEvent):void {
      DEBUG && ExternalInterface.call(callback, 'roll');

      var b = rRoll.arr.rotation,
        c = 360;

      function tween () {
        rRollItv = new Tween(rRoll.arr, 'rotation', None.easeNone, b, b + c, .5, true);
        rRollItv.looping = true;
      }

      function finish (event:TweenEvent) {
      }

      tween();

      rRollItv.addEventListener(TweenEvent.MOTION_FINISH, finish);

      rRoll.btn.enabled = false;
      rRoll.btn.mouseEnabled = false;

      if (codeUrl) {
        // 加载验证码
        loadCode(new MouseEvent(MouseEvent.CLICK));
      } else {
        // 加载中奖信息
        loadLuck();
      }
    }

    // 为地址添加随机串
    private function addrnd(url:String):String {
      if (DEBUG) {
        return url;
      }
      return url + (url.indexOf('?') === -1 ? '?' : '&') + new Date().getTime();
    }

    // 为地址添加参数
    private function addpar(url:String, key:String, val:String):String {
      if (DEBUG) {
        return url;
      }
      return url + (url.indexOf('?') === -1 ? '?' : '&') + key + '=' + escape(val);
    }

    private function _roll():void {
      roll(new MouseEvent(MouseEvent.CLICK));
    }

  }

}
