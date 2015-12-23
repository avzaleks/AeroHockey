//Constructors


// Constructor for line
function Line (x1,y1,x2,y2,name){
this.x1=x1;
this.z1=y1;
this.x2=x2;
this.z2=y2;
this.name=name;
this.run=this.x2-this.x1;
this.rise=this.z2-this.z1;
this.slope=function(){ 
	var sl=this.rise/this.run;
		if(sl===Infinity||sl===-Infinity){
			return 1000000;
		}
		if(sl===0){
			return 0.00000000001;
		}
		if(sl===-0){
			return -0.00000000001;
		}
	return sl;
	}
this.crossY=this.z2-this.x1*this.slope();
this.angle = Math.atan2(this.rise, this.run);
}

//Constructor for set of borders, which are an objects for collision 
function Limiter (){
this.boundsOfLine = [];
this.boundsOfRods = [];
this.addLine=function(obj){
    var args = arguments;
		for(var i=0;i<args.length;i++){
			this.boundsOfLine.push(args[i]);
		}
	}
this.addRod=function(obj){
    var args = arguments;
		for(var i=0;i<args.length;i++){
			this.boundsOfRods.push(args[i]);
		}
	}

this.remove=function(array, obj){array.pop(obj);};
this.listenToTheBorder=function(obj){

	for(var i=0;i<this.boundsOfLine.length;i++){
		var lineForCheck=this.boundsOfLine[i];
		var timeToCollision = timeToLineCollision(lineForCheck, obj);
	    if(timeToCollision<1){
	    	ion.sound.play("pop_cork");
	    	ballLineReaction(lineForCheck,obj);};
		}
	}
this.listenToTheRods=function(obj){
		for(var i=0;i<this.boundsOfRods.length;i++){
			var rodForCheck=this.boundsOfRods[i];
			detectCollisionForCircles(obj,rodForCheck);
		}
	}
}

//Constructor for cursor object
function Mouse(){
		this.flag=false;
		this.startPositionX=510;
		this.startPositionY=240;
		this.speedX=function(){
						if(this.flag){
						var speed=this.	startPositionX-this.lastPositionX;
						this.lastPositionX=this.startPositionX
						return speed;
							}else{return 0;}
						};
		this.speedY=function(){
						if(this.flag){
						var speed=this.startPositionY-this.lastPositionY;
						this.lastPositionY=this.startPositionY
						return speed;
							}else{return 0;}
						};
		this.lastPositionX=510;
		this.lastPositionY=240;
}

//Constructor for elements of table
var ElemOfTable = function(width, height, length, texture, x_poz, y_poz, z_poz){
	this.width=width;
	this.height=height;
	this.length=length;
	this.texture=texture;
	this.x_poz=x_poz;
	this.y_poz=y_poz;
	this.z_poz=z_poz;
	this.init = function(){
		var geom = new THREE.BoxGeometry(this.width, this.height, this.length, 40, 40);
		var loadTexture = new THREE.ImageUtils.loadTexture(this.texture);
		loadTexture.anisotropy = 24;
		var mat = new THREE.MeshPhongMaterial({map:loadTexture});
		var obj = new THREE.Mesh(geom, mat);
		obj.position.x = this.x_poz;
		obj.position.y = this.y_poz;
		obj.position.z = this.z_poz;
		
		return obj; 
	}	
};

//Constructor for playing object (cylinders) 
var PlayObject = function(radiusTop, radiusBottom, hight, hexColor, x_poz, y_poz, z_poz,name,mass){
	this.radiusTop=radiusTop;
	this.radiusBottom=radiusBottom;
	this.hight=hight;
	this.color=hexColor;
	this.x_poz=x_poz;
	this.y_poz=y_poz;
	this.z_poz=z_poz;
	this.name=name;
	this.mass=mass;
	this.init = function(){
		var geom =  new THREE.CylinderGeometry(this.radiusTop, this.radiusBottom, this.hight, 50, 30);
		var mat =  new THREE.MeshLambertMaterial({color:this.color});
		var obj = new THREE.Mesh(geom, mat);
		obj.position.x = this.x_poz;
		obj.position.y = this.y_poz;
		obj.position.z = this.z_poz;
		obj.radius=this.radiusTop>=this.radiusBottom?this.radiusTop:this.radiusBottom;
		obj.castShadow = true;
        obj.mass=this.mass;
		obj.move_x=0; 	
        obj.move_y=0;
        obj.move_z=0;
		return obj; 
	}
}

//Constructor for lighting
var Light = function(x, y , z){
    this.x = x;  
    this.y = y;	
    this.z = z;	
    var spotLight = new THREE.SpotLight( 0xffffff );
		spotLight.position.set(x, y, z);
		spotLight.castShadow = true;
		return spotLight ;	
    } 

//Constructor for text
var Text = function(text, size, height, curveSegments,color){
this.text=text;	
this.size=size;
this.height=height;
this.curveSegments=curveSegments;
this.color=color;
this.init = function(){
	//alert(this.text);
	var text3d = new THREE.TextGeometry( this.text, {
			size: this.size,
			height: this.height,
			curveSegments: this.curveSegments,
			font: "helvetiker"
		});
		text3d.computeBoundingBox();
	var centerOffset = -0.5 * ( text3d.boundingBox.max.x - text3d.boundingBox.min.x );
	//alert(centerOffset)
	var textMaterial = new THREE.MeshBasicMaterial({color:this.color});
	var text = new THREE.Mesh( text3d, textMaterial );
	    text.position.y=0;
	    text.position.z=-500;   
	
	return text;
	}	
}

//Functions

//Function to bind the cursor to the active object.
function onMouseMove(event) {
	if(!isThisPageForBroudcast){
	var poz = defineIntersection(event);
		if (cursor.flag){
			cursor.startPositionX=poz.x;
			cursor.startPositionY=poz.z;
			batThis.position.x=poz.x;
			batThis.position.z=poz.z;
			var bothPos = (poz.x+":"+poz.z);
			ws.send(bothPos);	
		}
	}                
}
//Function to synchronize the position of the cursor and active object
function onMouseClick(event) {
	if(!isThisPageForBroudcast){
	var poz = defineIntersection(event);
	if ((poz.x >= -40 && poz.x <= 40) && (poz.z >= 250 && poz.z <= 320) && !cursor.flag) {
		cursor.startPositionX = poz.x;
		cursor.startPositionY = poz.z;
		cursor.lastPositionX = poz.x;
		cursor.lastPositionY = poz.z;
		cursor.flag = true;
		sendCoords=true;
		 
	   } else {
	       alert("You do not fall into the desired position!!! Try again.");
	   }
	}
}		

//Function for detecting intersection with object
function defineIntersection(e){
	var	raycaster = new THREE.Raycaster();
	var vector = new THREE.Vector3();
		vector.set((event.clientX/containerWidth)*2-1,-(event.clientY/containerHeight)*2+1,0.5);
		vector.unproject( camera );
		raycaster.ray.set( camera.position, vector.sub( camera.position ).normalize() );
	var intersects = raycaster.intersectObject( plane );
        if(intersects.length>0){
           	for (var i=0;i<intersects.length;i++){
           		var inter=intersects[i];
           		return inter.point;	
	        }
        }
	}	 

//Function for change position of moving objects
function toRun (obj){
	var args = arguments;
	for(var i=0; i<args.length;i++){
		if(args[i].move_x>30){args[i].move_x=30;}
		if(args[i].move_z>30){args[i].move_z=30;}
		args[i].position.x += args[i].move_x;
		args[i].position.z += args[i].move_z;
	}
}

//Function for detecting collision moving objects to lines
function timeToLineCollision(tempLine,point){
	var slope2 =point.move_z/point.move_x;
		if (slope2 ==Number.POSITIVE_INFINITY){
			var slope2 =1000000;
		}else if (slope2 ==Number.NEGATIVE_INFINITY){
			var slope2 =-1000000;
		}
	var b2 =point.position.z-slope2*point.position.x;
	var x =(b2-tempLine.crossY)/(tempLine.slope()-slope2);
	var z =tempLine.slope()*x+tempLine.crossY;
	var theta =Math.atan2(point.move_z, point.move_x);
	var gamma =theta-tempLine.angle;
	var sinGamma = Math.sin(gamma);
	var r =point.radius/sinGamma;
	var xp =x-r*Math.cos(theta);
	var	zp =z-r*Math.sin(theta);
    var dis =Math.sqrt((xp-point.position.x)*(xp-point.position.x)+
						(zp-point.position.z)*(zp-point.position.z));
	var vel =Math.sqrt(point.move_x*point.move_x+point.move_z*point.move_z);
	var frames =dis/vel
    var slope2a =-1/tempLine.slope();
    var b2a =zp-slope2a*xp;
    var xa =(tempLine.crossY-b2a)/(slope2a-tempLine.slope());
        xa=Math.round(xa);
    var ya =slope2a*xa+b2a;
        ya=Math.round(ya);
	if ((xa>=tempLine.x1 && xa<=tempLine.x2)||(xa<=tempLine.x1 && xa>=tempLine.x2)
		||((ya>=tempLine.z1 && ya<=tempLine.z2)||(ya<=tempLine.z1 && ya>=tempLine.z2))){
	}else {
		var frames =1000;
	}
	return frames;
 }

//Function reactions for circle-line collision  
function ballLineReaction(tempLine,point,x,y){
	var alpha =tempLine.angle;
	var cosAlpha =Math.cos(alpha);
	var sinAlpha =Math.sin(alpha);
	var vyi =point.move_z;
	var vxi =point.move_x;
	var vyip =vyi*cosAlpha-vxi*sinAlpha;
	var vxip =vxi*cosAlpha+vyi*sinAlpha;
	var vyfp =-vyip;
	var vxfp =vxip;
	var vyf =vyfp*cosAlpha+vxfp*sinAlpha;
	var vxf =vxfp*cosAlpha-vyfp*sinAlpha;
		point.move_x =vxf;
		point.move_z =vyf;
    	ws1.send(point.move_x+":"+point.move_z+":"+point.position.x+":"+point.position.z);
        



}

//Function for detecting collision moving circles to other circles
function detectCollisionForCircles(obj1,obj2){
	
	var xmov1 = obj1.move_x;
	var ymov1 = obj1.move_z;
	var xmov2 = obj2.move_x;
	var ymov2 = obj2.move_z;
	
	var xl1=obj1.position.x;
    var yl1=obj1.position.z;
	var xl2=obj2.position.x;
	var yl2=obj2.position.z;
	var R = obj1.radius + obj2.radius;
	var a =-2*xmov1*xmov2+xmov1*xmov1+xmov2*xmov2;
	var b =-2*xl1*xmov2-2*xl2*xmov1+2*xl1*xmov1+2*xl2*xmov2;
	var c =-2*xl1*xl2+xl1*xl1+xl2*xl2;
	var d =-2*ymov1*ymov2+ymov1*ymov1+ymov2*ymov2;
	var e =-2*yl1*ymov2-2*yl2*ymov1+2*yl1*ymov1+2*yl2*ymov2;
	var f =-2*yl1*yl2+yl1*yl1+yl2*yl2;
	var g =a+d;
	var h =b+e;
	var k =c+f-R*R;
			
	var sqRoot =Math.sqrt(h*h-4*g*k);
	var t1 =(-h+sqRoot)/(2*g);
	var t2 =(-h-sqRoot)/(2*g);
	
	  /*  if (t1>0 &&t1<=1){
		    var  whatTime =t1;
			var ballsCollided =true;
			alert("t1="+whatTime);
	    } */
		if (t2>0 &&t2<=1){
		    if (whatTime ==0 ||t2<t1){
           		var	whatTime =t2;
				var	ballsCollided =true;
		    }
		}
		if (ballsCollided){
			
			ball2BallReaction(obj1,obj2,xl1,xl2,yl1,yl2,whatTime)
				ballsCollided=false;
				whatTime=0;
			}
				
}		


//Function for detecting collision moving circles to other circles

function anotherDetectCollisionForCircles(obj1,obj2){
var distX=obj1.position.x-obj2.position.x;
var distZ=obj1.position.z-obj2.position.z;
var distance=Math.sqrt(distX*distX+distZ*distZ);
var rad = obj1.radius+obj2.radius;
if(distance<rad){
	ball2BallReaction(obj1,obj2,obj1.position.x,
			obj2.position.x,obj1.position.z,
			obj2.position.z);
		}
}


//Function reaction for moving circles
function ball2BallReaction(obj1,obj2,x1,x2,y1,y2,time){
	var mass1 =obj1.mass;
	var mass2 =obj2.mass;

	var xVel1 =obj1.move_x;
	var xVel2 =obj2.move_x;
	var yVel1 =obj1.move_z;
	var yVel2 =obj2.move_z;
	//alert(xVel2+"  "+yVel2);
	var run =(x1-x2);
	var rise =(y1-y2);
	var Theta =Math.atan2(rise,run);
	var cosTheta =Math.cos(Theta);
	var sinTheta =Math.sin(Theta);
	var xVel1prime =xVel1*cosTheta+yVel1*sinTheta;
	var xVel2prime =xVel2*cosTheta+yVel2*sinTheta;
	var yVel1prime =yVel1*cosTheta-xVel1*sinTheta;
	var yVel2prime =yVel2*cosTheta-xVel2*sinTheta;
	var P =(mass1*xVel1prime+mass2*xVel2prime);
	var V =(xVel1prime-xVel2prime);
	var v2f =(P+mass1*V)/(mass1+mass2);
	var v1f =v2f-xVel1prime+xVel2prime;
	var xVel1prime =v1f;
	var xVel2prime =v2f;
	var xVel1 =xVel1prime*cosTheta-yVel1prime*sinTheta;
	var xVel2 =xVel2prime*cosTheta-yVel2prime*sinTheta;
	var yVel1 =yVel1prime*cosTheta+xVel1prime*sinTheta;
	var yVel2 =yVel2prime*cosTheta+xVel2prime*sinTheta;
	    ion.sound.play("metal_plate_2");
	    obj1.move_x =xVel1;
		//obj2.move_x =xVel2;
		obj1.move_z =yVel1;
		//obj2.move_z =yVel2;
        if(obj2===batThis){
              	ws1.send(obj1.move_x+":"+obj1.move_z+":"+obj1.position.x+":"+obj1.position.z);
        } 
}					

var score = (function(){
	var my=0;
	var his=0;	
	return  function(obj){
		if (obj.position.z<-400){
			ion.sound.play("bell_ring");
			++my;
			scene.remove(myScore);
			myScore = new Text(my+"", 240, 40, 20, 0xff00ff).init();
			myScore.position.x=-800;
			scene.add(myScore);
		    obj.position.z=200;
		    obj.position.x=10;
		    obj.move_x=0.01;
		    obj.move_z=-0.01;
		}
		if(obj.position.z>400){
			ion.sound.play("light_bulb_breaking");
			++his;
			scene.remove(hisScore);
		    hisScore = new Text(his+"", 240, 40, 20, 0x0000ff).init();
		    hisScore.position.x=700;
		    scene.add(hisScore);
		    obj.position.z=-200;
		    obj.position.x=10;
		    obj.move_x=0.01;
		    obj.move_z=0.01;		
		}
	}
})();

	function letsGo(){
		var words=["three", "two", "one", "go"];
		var i=0;
		var	word = new Text(words[i], 400, 80, 20, 0x9900FF).init();
		word.position.z=500;
		word.position.y=100;
		word.position.x=-400;
		scene.add(word);
		var firsInter=setInterval(function(){
			word.position.z+=20;
			word.position.y+=15;
			},40);
		var inter=setInterval(function(){
			 var secInter=setInterval(function(){
				word.position.z+=20;
				word.position.y+=15;
			},40);
			++i
			scene.remove(word);
			word = new Text(words[i], 400, 80, 20, 0x9900FF).init();
			word.position.z=500;
			word.position.y=100;
			word.position.x=-400;
			scene.add(word);
			if(i>=4){
				scene.remove(word);
				clearInterval(inter);
				clearInterval(secInter);
				scene.remove(particleSystem);
				particleSystem=null;
			}
		},1500)
	}
	
	
function rotationCloud(){
	if(particleSystem){
		var timeForPart = Date.now() * 0.001;
	 	particleSystem.rotation.x = timeForPart * 0.25;
		particleSystem.rotation.y = timeForPart * 0.5;
	}
}	






