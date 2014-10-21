(function (exports, undefined) {

/**
 * FLASH转盘
 * @module Rotable
 */

// 获取当前脚本路径目录
var scripts = document.getElementsByTagName('script'),
  currentPath = scripts[scripts.length - 1].src,
  currentFolder = currentPath.substr(0, currentPath.lastIndexOf('/') + 1);

/**
 * Class Rotable
 * @class Rotable
 * @param {object} options 配置参数
 * @example
 *  ```
 *  var rotable = new Rotable({
 *   containerId: 'flashContent',
 *   flashvars: {
 *     dataUrl: 'data.xml',
 *     luckUrl: 'luck.xml',
 *     callback: 'console.log'
 *   }
 *  });
 *  ```
 * @constructor
 */
var Rotable = function (options) {
  this.init(options);
};

Rotable.instance = {};

Rotable.prototype = {

  /**
   * SWF文件地址
   * @property .movieUrl
   * @private
   */
  movieUrl: currentFolder + '../swf/@NAME-@VERSION.swf',

  /**
   * 生成唯一ID
   * 用于Object标签的id属性值
   * @method .makeId
   * @private
   */
  makeId: function () {
    this.movieId = (new Date().getTime()).toString(36);

    if (Rotable.instance[this.movieId]) {
      this.movieId += parseInt(Math.random() * 1000, 10);
    }

    Rotable.instance[this.movieId] = true;

  },

  /**
   * 初始化转盘（嵌入SWF文件）
   * @param {object} options 配置参数
   * @method .init
   */
  init: function (options) {

    var flashvars = [];

    if (options.debug) {
      flashvars.push('debug=1');
    }

    if (options.flashvars) {
      for (var i in options.flashvars) {
        flashvars.push(i + '=' + options.flashvars[i]);
      }

      flashvars = flashvars.join('&amp;');
    }

    this.makeId();

    document.getElementById(options.containerId).innerHTML =
      '<object ' +
        (!!window.ActiveXObject ?
          'classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"':
          'type="application/x-shockwave-flash" data="' + this.movieUrl + '"') +
        ' width="100%" height="100%" id="' + this.movieId + '">' +
        '<param name="movie" value="' +  this.movieUrl + '" />' +
        '<param name="quality" value="high" />' +
        '<param name="bgcolor" value="#ffffff" />' +
        '<param name="wmode" value="transparent" />' +
        '<param name="scale" value="showall" />' +
        '<param name="menu" value="false" />' +
        '<param name="allowScriptAccess" value="sameDomain" />' +
        '<param name="flashvars" value="' + flashvars + '" />' +
      '</object>';
  },

  /**
   * 调用转盘转动
   * @method .roll
   */
  roll: function () {
    document[this.movieId].roll();
  }

};

exports.Rotable = Rotable;

})(this);
