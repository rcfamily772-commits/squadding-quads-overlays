(()=>{"use strict";
const $=id=>document.getElementById(id),canvas=$("screen"),ctx=canvas.getContext("2d");
const themes=[[52,207,255],[95,247,116],[255,88,46],[239,189,91],[192,99,255]],names=["ION BLUE","TOXIC GREEN","MOLTEN RED","BLACK GOLD","NEON VIOLET"];
let phase=0,last=performance.now(),start=last;
const reduced=matchMedia("(prefers-reduced-motion: reduce)");
if(reduced.matches)$("speed").value="0";
$("size").addEventListener("change",()=>{let [w,h]=$("size").value.split("x").map(Number);canvas.width=w;canvas.height=h;});
function frame(now){let dt=Math.min(50,Math.max(0,now-last));last=now;
let w=canvas.width,h=canvas.height,t=+$("theme").value,p=themes[t],speed=+$("speed").value,e=+$("energy").value/100;
$("energyValue").value=Math.round(e*100)+"%";
if(speed)phase=(phase+dt/10*(.045*speed+.13*e))%96;
const c=(k=1)=>"rgb("+p.map(v=>Math.round(v*k)).join(",")+")",bg="#05090f",panel="#0c141c",white="#e5f2f9",muted="#7691a0";
ctx.fillStyle=bg;ctx.fillRect(0,0,w,h);
let wide=w>=320&&h>=175,cx=Math.floor(w/2),cy=wide?Math.floor((h+3)/2):Math.floor(h/2),r=Math.floor(Math.min(w*(wide?.25:.43),h*(wide?.37:.40))),q=Math.floor(phase);
function line(x,y,X,Y,col,l=1){ctx.strokeStyle=col;ctx.lineWidth=l;ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(X,Y);ctx.stroke()}
function circle(x,y,R,col,fill=false,l=1){if(R<=0)return;ctx.beginPath();ctx.arc(x,y,R,0,Math.PI*2);if(fill){ctx.fillStyle=col;ctx.fill()}else{ctx.strokeStyle=col;ctx.lineWidth=l;ctx.stroke()}}
function pt(R,a){let z=a*Math.PI/48;return[cx+R*Math.cos(z),cy+R*Math.sin(z)]}
function radial(a,b,j,col,l=1){line(...pt(a,j),...pt(b,j),col,l)}
function arc(R,a,len,col,l=1){ctx.beginPath();ctx.arc(cx,cy,R,a*Math.PI/48,(a+len)*Math.PI/48);ctx.strokeStyle=col;ctx.lineWidth=l;ctx.stroke()}
function text(x,y,v,col=white,size=12,align="left"){ctx.fillStyle=col;ctx.font="600 "+size+"px system-ui";ctx.textAlign=align;ctx.textBaseline="top";ctx.fillText(v,x,y)}
for(let i=1;i<=3;i++){let a=2+i*3;ctx.strokeStyle=i===1?c(.22):panel;ctx.lineWidth=1;ctx.strokeRect(a,a,w-2*a,h-2*a)}
if(wide){text(14,9,"SQ / REACTOR",c());text(w-14,9,names[t],c(),12,"right");line(14,28,w-15,28,c(.22));line(14,h-26,w-15,h-26,c(.22));text(14,h-22,"BLACK LABEL / V1.0",muted,10);text(w-14,h-22,speed?"REACTOR ONLINE":"STATIC",muted,10,"right")}
circle(cx,cy,r-1,c(.10),true);circle(cx,cy,r,c(.22));circle(cx,cy,r*.91,c(.52));
for(let i=0;i<24;i++)radial(r*.93,r,i*4,i%3===0?c():c(.22));
for(let i=0;i<4;i++){arc(r*.84,q+i*24,15,c(),2);arc(r*.81,q+i*24,15,c(.52));arc(r*.72,-q+i*24,13,c(.52));arc(r*.69,-q+i*24,13,c(),2)}
for(let i=0;i<8;i++){let a=q+i*12;radial(r*.53,r*.66,a,c(.52));radial(r*.53,r*.66,a+1,c(.52));circle(...pt(r*.64,a),Math.max(1,r*.021),c(),true)}
let core=r*.46,pulse=speed?(e>.65?.78:[.34,.45,.60,.78][Math.floor(q/8)%4]):.45;
circle(cx,cy,core,c(.18),true);circle(cx,cy,core,c(),2);circle(cx,cy,core*.8,c(pulse),true);circle(cx,cy,core*.6,c(.18),true);
if(core>=14){let label=core>=26?($("call").value||"SQ"):"SQ",size=core>=29?22:12;ctx.font="600 "+size+"px system-ui";if(ctx.measureText(label).width>core*1.7)label="SQ";text(cx,cy-size/2,label,white,size,"center")}
for(let i=0;i<6;i++)circle(...pt(r*.96,q*2+i*16),Math.max(1,r*.018),white,true);
if(wide){let side=Math.floor(cx-r-20),y=Math.floor(h*.28),x=w-side-12,sec=Math.floor((now-start)/1000),session=String(Math.floor(sec/60)%100).padStart(2,"0")+":"+String(sec%60).padStart(2,"0");function meter(X,Y,l,v){line(X,Y,X+side,Y,c(.22));text(X,Y+4,l,muted,11);text(X,Y+18,v,white,21)}if(side>=58){meter(12,y,"TX VOLTS",$("tele").checked?"7.8V":"--");meter(12,y+Math.floor(h*.27),"SESSION",session);meter(x,y,"RF LINK",$("tele").checked?"100%":"--");meter(x,y+Math.floor(h*.27),"STICK FX",Math.round(e*100)+"%")}}else if(h>=90&&w>=100)text(cx,h-16,"SQ REACTOR",c(),11,"center");
requestAnimationFrame(frame)}
requestAnimationFrame(frame);
})();