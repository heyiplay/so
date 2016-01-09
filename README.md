# 模块简介
#### 合一媒体播放器SO模块，主要用于各端存取播放相关的本地数据信息，而不用依赖播放器的存在。存取值可以是任何 ActionScript 或 JavaScript 类型的对象（数组、数字、布尔值、字节数组、XML，等等）flash、js、c++ 各端均可单独载入使用此模块调用存取播放共享对象；

使用方法及测试DEMO见bin目录下的index.html。

Author: 8088 [flasher.jun@gmail.com]
License: [MIT](http://opensource.org/licenses/MIT) 

## SharedObject的本地保存路径

* Windows XP

	网络访问： C:\Documents and Settings\[用户名]\Application Data\Macromedia\Flash Player\#SharedObjects\[随机码]\[网站域名]\[页面目录]\[sharedobject实际对象名].sol

	AIR 程序： C:\Documents and Settings\[用户名]\Application Data\[AIR 程序逆域名 ]\Local Store\#SharedObjects\[flash程序名].swf\[sharedobject实际对象名].sol

* Windows Vista

	C:/Users/username/[用户名]/AppData/Roaming/Macromedia/Flash Player/#SharedObjects/[网站域名]/[页面目录]/[flash程序名].swf/[sharedobject实际对象名].sol

* Linux/Unix

	/home/[用户名]/.macromedia/Flash_Player/#SharedObjects/[网站域名]/[页面目录] /[flash程序名].swf/[sharedobject实际对象名].sol

* Mac OS X:

	网络访问： Macintosh HD:Users:[用户名]:Library:Preferences:Macromedia:Flash Player:#SharedObjects:[随机码]:[网站域名]:[页面目录]\[sharedobject实际对象名].sol


&copy; Copyright 2014 YoukuTudou Team
