(function(e){function n(n){for(var i,a,r=n[0],l=n[1],d=n[2],s=0,g=[];s<r.length;s++)a=r[s],Object.prototype.hasOwnProperty.call(t,a)&&t[a]&&g.push(t[a][0]),t[a]=0;for(i in l)Object.prototype.hasOwnProperty.call(l,i)&&(e[i]=l[i]);u&&u(n);while(g.length)g.shift()();return c.push.apply(c,d||[]),o()}function o(){for(var e,n=0;n<c.length;n++){for(var o=c[n],i=!0,r=1;r<o.length;r++){var l=o[r];0!==t[l]&&(i=!1)}i&&(c.splice(n--,1),e=a(a.s=o[0]))}return e}var i={},t={app:0},c=[];function a(n){if(i[n])return i[n].exports;var o=i[n]={i:n,l:!1,exports:{}};return e[n].call(o.exports,o,o.exports,a),o.l=!0,o.exports}a.m=e,a.c=i,a.d=function(e,n,o){a.o(e,n)||Object.defineProperty(e,n,{enumerable:!0,get:o})},a.r=function(e){"undefined"!==typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},a.t=function(e,n){if(1&n&&(e=a(e)),8&n)return e;if(4&n&&"object"===typeof e&&e&&e.__esModule)return e;var o=Object.create(null);if(a.r(o),Object.defineProperty(o,"default",{enumerable:!0,value:e}),2&n&&"string"!=typeof e)for(var i in e)a.d(o,i,function(n){return e[n]}.bind(null,i));return o},a.n=function(e){var n=e&&e.__esModule?function(){return e["default"]}:function(){return e};return a.d(n,"a",n),n},a.o=function(e,n){return Object.prototype.hasOwnProperty.call(e,n)},a.p="";var r=window["webpackJsonp"]=window["webpackJsonp"]||[],l=r.push.bind(r);r.push=n,r=r.slice();for(var d=0;d<r.length;d++)n(r[d]);var u=l;c.push([0,"chunk-vendors"]),o()})({0:function(e,n,o){e.exports=o("56d7")},4459:function(e,n,o){"use strict";o("54de")},"54de":function(e,n,o){},"56d7":function(e,n,o){"use strict";o.r(n);var i=o("7a23"),t=o("8fd5"),c=o.n(t);const a=Object(i["d"])("audio",{id:"audio_on",src:"mic_click_on.ogg"},null,-1),r=Object(i["d"])("audio",{id:"audio_off",src:"mic_click_off.ogg"},null,-1),l=Object(i["d"])("div",{id:"logo"},[Object(i["d"])("img",{src:c.a,class:"ribbon"})],-1),d={class:"voiceInfo"};function u(e,n,o,t,c,u){return Object(i["e"])(),Object(i["b"])("body",null,[a,r,l,Object(i["d"])("div",d,[0!==t.voice.callInfo?(Object(i["e"])(),Object(i["b"])("p",{key:0,class:{talking:t.voice.talking}}," [Call] ",2)):Object(i["c"])("",!0),t.voice.radioEnabled&&0!==t.voice.radioChannel?(Object(i["e"])(),Object(i["b"])("p",{key:1,class:{talking:t.voice.usingRadio}},Object(i["g"])(t.voice.radioChannel)+" Mhz [Radio] ",3)):Object(i["c"])("",!0),t.voice.warningMsg?(Object(i["e"])(),Object(i["b"])("p",{key:2,class:{warning:t.voice.warningMsg}}," [Warning] "+Object(i["g"])(t.voice.warningMsg),3)):!t.voice.warningMsg&&t.voice.voiceModes.length?(Object(i["e"])(),Object(i["b"])("p",{key:3,class:{talking:t.voice.talking}}," [Mumble] "+Object(i["g"])(t.voice.voiceModes[t.voice.voiceMode][1]),3)):Object(i["c"])("",!0)])])}var s={name:"App",setup(){const e=Object(i["f"])({voiceModes:[],voiceMode:0,radioChannel:0,radioEnabled:!1,usingRadio:!1,callInfo:0,talking:!1,warningMsg:null});let n=!1;return window.addEventListener("message",(function(o){const i=o.data;if(void 0!==i.warningMsg&&(e.warningMsg=i.warningMsg),void 0!==i.voiceModes&&(e.voiceModes=JSON.parse(i.voiceModes)),void 0!==i.voiceMode&&(e.voiceMode=i.voiceMode),void 0!==i.radioChannel&&(e.radioChannel=i.radioChannel),void 0!==i.radioEnabled&&(e.radioEnabled=i.radioEnabled),void 0!==i.callInfo&&(e.callInfo=i.callInfo),i.usingRadio!==e.usingRadio&&(n=!0,e.usingRadio=i.usingRadio,n=!1),void 0===i.talking||e.usingRadio||n||(e.talking=i.talking),i.sound&&e.radioEnabled){let e=document.getElementById(i.sound);e.load(),e.volume=i.volume,e.play().catch(e=>{})}})),{voice:e}}};o("4459");s.render=u;var g=s;Object(i["a"])(g).mount("#app")},"8fd5":function(e,n,o){e.exports=o.p+"img/logo.png"}});