<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>


<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="styles/style.css" />

<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<script src="script/three.min.js"></script>
<script src="script/FirstPersonControls.js"></script>
<script src="script/ObjectsAndFunctions.js"></script>
<script src="script/helvetiker_regular.typeface.js"></script>
<script src="script/ion.sound.min.js"></script>

<title>AeroHockey</title>
<style>
</style>
<script type="text/javascript">
var host=window.location.href.split("?")[0];
console.log(host);
var wsLocation = host.replace("http", "ws").replace("aero", "mss/")
console.log(wsLocation);
var ws=new WebSocket(wsLocation + '${rId}');
</script>

<script>
	var ws;	
	var timeForStart;
  	var xFromWS=0;
	var zFromWS=-300;
	var sendCoords=false;
	var started=false;
	var ws1;
	var isThisPageForBroudcast=false;

	$(document).ready(function(){
		$("#inp").val(host + "?opponentId=" + '${rId}');
		
		
		
		
		
		if("${opponentId}"){
			$("#start").show();
			$("#urlDiv").hide();
			$("#opponentIdDiv").show();
		}	
		
		setInterval(function(){
			$("#img").attr("src","images/eyes1.jpg");
				setTimeout(function(){
					$("#img").attr("src","images/eyes.jpg");
			},100);
		},3000);
		
				
		ws1 = new WebSocket(wsLocation + '${rId}'+'dop');
				
		ws.onopen = function(){
			$("#fmsgs").html("Web socket has been opened.");
		}
			
		ws1.onopen = function(){
//		console.log("Web socket number two has been opened."+"from ws1");
		}
     	
		ws.onmessage = function(message) {
            if(isThisPageForBroudcast){
				if(message.data.indexOf("f")>-1){
					batThis.position.x=parseInt(message.data.split(":")[0]);
					batThis.position.z=parseInt(message.data.split(":")[1]);
				}else{
					var tempX=-parseInt(message.data.split(":")[0]);
		    		var tempZ=-parseInt(message.data.split(":")[1]);
	 	    			if(tempX&&tempZ){
		    				xFromWS=tempX;
			    			zFromWS=tempZ;
	 	    			}
					}
			}else{
				var tempX=-parseInt(message.data.split(":")[0]);
	    		var tempZ=-parseInt(message.data.split(":")[1]);
 	    			if(tempX&&tempZ){
	    				xFromWS=tempX;
		    			zFromWS=tempZ;
 	    			}else if(message.data.indexOf("time")>-1){
 	    						timeForStart=parseInt(message.data.split(":")[1]);
 	    						
 	    						var interv=setInterval(function(){
 	    							var timeNow=new Date().getTime();
 	    							console.log(timeNow);
 	    						
 	    							if ((timeForStart+2000)<=timeNow){
 	    								started=true;
 	    								clearInterval(interv);
	    							}   

 	    								
 	    						},1)
 	    					
 	    			} 
		
		  	}
		}

		ws1.onmessage = function(message) {
			console.log(message.data+"                   from ws1");
			var speedX=-parseInt(message.data.split(":")[0]);
			var speedZ=-parseInt(message.data.split(":")[1])
			var posX =-parseInt(message.data.split(":")[2]);
			var posZ =-parseInt(message.data.split(":")[3]);
					
			if(speedX && speedZ ){
				puck.position.x=posX;
				puck.position.z=posZ;
				puck.move_x=speedX;
				puck.move_z=speedZ;
			}
			if(message.data.indexOf("stop")>-1){
				$("#forTrans").show();
				$("#info").show();
				$("#stopGame").hide();
		        scene.remove(puck);  
				
			}
		
		
		
		}
						

	
		$("#start").on("click",function() {
				$.get( host, {
					        game:"start",
					        clientId: $("#clientId").val(),	   
							opponentId: $("#opponentId").val(),
							clientIddop: $("#clientId").val()+"dop",
							opponentIddop: $("#opponentId").val()+"dop"})
							$("#forTrans").hide();
							$("#info").hide(); 		
									
							
		});
					
		$("#stopGame").click(function(){
			$.get( host , {
		        game:"stop",
		        clientId: $("#clientId").val(),	   
				opponentId: $("#opponentId").val(),
				clientIddop: $("#clientId").val()+"dop",
				opponentIddop: $("#opponentId").val()+"dop"})
				
				
		})
		
		
		$("#getSessions").click(function(){
			$.ajax({url: host +"?watch=false&id="+$("#clientId").val(),
	    		success: function(result){
		        	console.log(result);
		        	$("#sel").empty();
		        	$.each(result, function(key, val) {
		            $("#sel").append('<option>' + val + '</option>');
		    	   console.log(key +"  "+val)
		        });
		    }});
		});
		
        $("#begin").click(function(){
        	if($("#begin").val()==="Begin to show"){
        	   	if($("#sel").val()==null){
        		alert("Now no one is playing. Try after some time.");   	
        		}
        		if($("#sel").val()!=null){
        		scene.add(puck);
        		$.get( host + "?watch=true&idForTrans="+$("#sel").val()+
        			"&myId="+$("#clientId").val()
        		);	   
        		$("#notWatch").hide();
        		$("#sel").hide();
        		$("#begin").val("Stop to show game of: "+$("#sel").val());
        		$("#par").hide();
        		}
        	}else if($("#begin").val()!=="Begin to show"){
        		$("#notWatch").show();
        		$("#sel").show();
        		$("#begin").val("Begin to show");
        		$("#par").show();
        		isThisPageForBroudcast=false;
        		puck.position.x=0;
        		puck.position.z=0;
        		scene.remove(puck);
        		batThis.position.x=0;
        		batThis.position.z=300;
        		batThat.position.x=0;
        		batThat.position.z=-300;
        		
        		$.get( host+"?watch=stop&idForTrans="+$("#sel").val()+
            			"&myId="+$("#clientId").val()
            	);	   
            }
        });
        
        
		
		
		
		$("#understand").on("click",function() {
			$("#rules").hide(2000);  	
			$("#nonunderstand").show();
		});
					
		$("#nonunderstand").on("click",function() {
			ion.sound.play("light_bulb_breaking");
			$("#rules").show(2000);  	
			$("#nonunderstand").hide();
		});
				
		$("#watch").on("click",function() {
			isThisPageForBroudcast=true;
			$("#watch").hide();  	
			$("#notWatch").show();  	
			$("#field").show(1500);
		    $("#info").hide();
		});
		
		$("#btnForNotWatch").on("click",function() {
			$("#watch").show();  	
			$("#notWatch").hide();  	
			$("#field").hide();
			isThisPageForBroudcast=false;
			$("#info").show();
		});
		
		
		$(window).unload(function(){ 
			  ws.close();
			  ws1.close();
        });
		
	});
</script>
</head>
<body>
	<div id="WebGL-output">
		<div id="msgs">
			<div id="idOfpage">
				<p >Your ID is: 
					<input type="text" value="${rId}" size="10" id="clientId">
				</p>
			</div>
			<div id="info">
				<div id="urlDiv">
					<p>This url you must send your opponent</p>
					<input id="inp" type="text" size="50" id="url">
				</div>
				<div id="opponentIdDiv">
				<p>Your opponent ID is:
					<input type="text" value="${opponentId}" size="10" id="opponentId">
				</p>
				</div>
			<p id="fmsgs"></p>
            <input type="button" value="Let's play"  id="start">
			</div>
			<input type="button" value="Stop game"  id="stopGame">
		
		</div>
		<div id="rules">
			<fieldset>
				<legend>Rules</legend>
				<p>Please look for these rules before the game</p>
				<ul>
					<li>For change the viewpoint, use next keys - W,A,S,D,R,F. </li>
					<li>For establish contact with an opponent you have choose his
		 				ID from the list and press enter</li>
	            	<li>To start managing the bat you should place the
	                	cursor over it and press any button of the mouse</li>
				</ul>
				<div id="understand">		
					<input type="button" value="If you understand click here" >
				</div>
			</fieldset>
		</div>
		<div id="nonunderstand">
			<input type="button" value="Rules" >
		</div>
	   <div id="forTrans">
	    	<div id="field">
        		<fieldset >
					<legend>Selection of games</legend>
					 <p id="par"> Select the current game from this list</p> 
					<select id="sel">
				  	</select>
					<input type="button" value="Begin to show" id="begin">
            	</fieldset>
			</div>
			<div id="watch">
				<button id="getSessions">
               	<img id="img" src="images/eyes.jpg" alt="" style="vertical-align:middle"> 
               	Watch game
                </button>
			</div>
        	<div id="notWatch">
				<input type="button" value="Not to look" size="35" id="btnForNotWatch">
			</div>	
		</div>
	</div>
<script type="text/javascript">

ion.sound({
    sounds: [{
            name: "pop_cork"
        },{
            name: "door_bell",
        },{
            name: "light_bulb_breaking",
        },{
            name: "metal_plate_2",
            volume: 0.3,        
        },{
            name: "bell_ring",
        }
        ],
    volume: 0.5,
    path: "sounds/",
    preload: true
});
</script>
<script>
			var scene = new THREE.Scene();
            
			var camera = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 0.1, 11000 );
                camera.position.y = 1030;
				camera.position.z = 1500;
				camera.rotation.z = -Math.PI/20;
				scene.add(camera);

			var controls;
				controls = new THREE.FirstPersonControls(camera);
				controls.movementSpeed = 1000;
				controls.lookSpeed = 0.05;

			var renderer = new THREE.WebGLRenderer();
				renderer.setClearColor(new THREE.Color(0xEEEEEE, 1.0));
				renderer.setSize(window.innerWidth, window.innerHeight);
				renderer.shadowMapEnabled = true;
		 
			var container = document.getElementById("WebGL-output");
				container.appendChild(renderer.domElement);
			
			    // create the floor
		    var floorGeometry = new THREE.PlaneBufferGeometry(4000,4000);
		    var loadTexture = new THREE.ImageUtils.loadTexture("images/textureForPlane.jpg");
			var floorMaterial = new THREE.MeshPhongMaterial({map:loadTexture});
		    var floor = new THREE.Mesh(floorGeometry,floorMaterial);
                // rotate and position the flor
		        floor.rotation.x=-0.5*Math.PI;
		        floor.position.x=0;
		        floor.position.y=-500;
		        floor.position.z=0;
		        floor.receiveShadow  = true;
		        // add the floor to the scene
		        scene.add(floor);
				
		     // create the back wall
			var backWallGeometry = new THREE.PlaneBufferGeometry(4000,2500);
		    var loadTexture = new THREE.ImageUtils.loadTexture("images/textureForWall.jpg");
			var backWallMaterial = new THREE.MeshPhongMaterial({map:loadTexture});
		    var backWall = new THREE.Mesh(backWallGeometry,backWallMaterial);
                // rotate and position the wall
		        //floor.rotation.x=-0.5*Math.PI;
		        backWall.position.x=0;
		        backWall.position.y=750;
		        backWall.position.z=-2000;
				backWall.receiveShadow = true;		       
		        // add the plane to the scene
		        scene.add(backWall);
				
	
		        // create the left wall
			var leftWallGeometry = new THREE.PlaneBufferGeometry(4000,2500);
			var loadTexture = new THREE.ImageUtils.loadTexture("images/textureForWall.jpg");
			var leftWallMaterial = new THREE.MeshPhongMaterial({map:loadTexture});
			var leftWall = new THREE.Mesh(leftWallGeometry,leftWallMaterial);
	            // rotate and position the wall
			    leftWall.rotation.y=0.5*Math.PI;
			    leftWall.position.x=-2000;
			    leftWall.position.y=750;
			    leftWall.position.z=0;
			    scene.add(leftWall);
		     
			    // create the right wall			    
			var rightWallGeometry = new THREE.PlaneBufferGeometry(4000,2500);
			var loadTexture = new THREE.ImageUtils.loadTexture("images/textureForWall.jpg");
			var rightWallMaterial = new THREE.MeshPhongMaterial({map:loadTexture});
			var rightWall = new THREE.Mesh(rightWallGeometry,rightWallMaterial);
		        // rotate and position the wall
			    rightWall.rotation.y=-0.5*Math.PI;
			    rightWall.position.x=2000;
			    rightWall.position.y=750;
			    rightWall.position.z=0;
			    scene.add(rightWall);
			     
		    	//Creation of the table
		    var plane = new ElemOfTable(500, 10, 800, "images/textureForAero.jpg", 0, 0, 0).init();
                plane.receiveShadow  = true;
                scene.add(plane);

            var lBort = new ElemOfTable(10, 40, 800, "images/textureForBort.jpg", -255, 15, 0).init();
			    scene.add( lBort );
			
			var rBort = new ElemOfTable(10, 40, 800, "images/textureForBort.jpg", 255, 15, 0).init();
                scene.add( rBort );
			
			var backLeftBort = new ElemOfTable(210, 40, 10, "images/textureForBort.jpg", -155, 15, -405).init();
				scene.add(backLeftBort);		
			
			var backRightBort = new ElemOfTable(210, 40, 10, "images/textureForBort.jpg", 155, 15, -405).init();
                scene.add(backRightBort);			
			
			var frontLeftBort = new ElemOfTable(210, 40, 10, "images/textureForBort.jpg", -155, 15, 405).init();
                scene.add(frontLeftBort);			
			
			var frontRightBort = new ElemOfTable(210, 40, 10, "images/textureForBort.jpg", 155, 15, 405).init();
                scene.add(frontRightBort);			  
		
			
            var tableLegGeom = new THREE.CylinderGeometry( 100, 50, 500, 50, 30);
    		var tableLegMat = new THREE.MeshLambertMaterial({color: 0xbbbbbb});
    		var tableLeg = new THREE.Mesh(tableLegGeom, tableLegMat );
    		tableLeg.position.x = 0;
    		tableLeg.position.y =-265;
    		tableLeg.position.z = 0;
    		tableLeg.castShadow = true;
    		scene.add(tableLeg);  
                
            var tableLegGeom2 = new THREE.CylinderGeometry(50, 150, 200, 50, 30);
      		var tableLegMat2 = new THREE.MeshLambertMaterial({color: 0xbbbbbb});
      		var tableLeg2 = new THREE.Mesh(tableLegGeom2, tableLegMat2 );
	      		tableLeg2.position.x = 0;
	      		tableLeg2.position.y =-415;
	      		tableLeg2.position.z = 0;
	      		tableLeg2.castShadow = true;
	      		scene.add(tableLeg2);       
	                        
                //Creating borders
          	var line1=new Line (-250,-400,-250, 400, 'line1');
			var line2=new Line (250, 400, 250, -400, 'line2');
			var line3=new Line (-35, -400, -250, -400, 'line3');
			var line4=new Line (250, -400, 35, -400, 'line4');
			var line5=new Line (-250, 400, -35, 400, 'line5');
			var line6=new Line (35, 400, 250, 400, 'line6');
			      
			var borders = new Limiter ();
				borders.addLine(line1, line2, line3, line4, line5, line6);
		     
                
            var rod1= new PlayObject(0,0,10,0xff0000,-45,20,-400,"rod1",10).init();
            var rod2= new PlayObject(0,0,10,0xff0000, 45,20,-400,"rod1",10).init();
            var rod3= new PlayObject(0,0,10,0xff0000,45,20,400,"rod1",10).init();
            var rod4= new PlayObject(0,0,10,0xff0000,-45,20,400,"rod1",10).init();
           
				borders.addRod(rod1,rod2,rod3,rod4);           
                            
           
                //puck
            var puck= new PlayObject(30,30,10,0xff0000,0,20,0,"puck",1).init();
				//scene.add(puck);
                puck.move_x=0.01;
                puck.move_z=0.01;
			
				//bats
			var batThis = new PlayObject(20,20,10,0xff00ff,0,20,300,"batThis",10).init();
				scene.add(batThis);
			
			var batThat = new PlayObject(20,20,10,0x0000FF,xFromWS,20,zFromWS,"batThat",10).init();
				batThat.position.x=xFromWS;
				batThat.position.z=zFromWS;
			    scene.add(batThat);
			
			var containerWidth = container.clientWidth;
		    var containerHeight = container.clientHeight;
			
		    	//Kit of objects to determine the intersection
		    var objects = [];
				objects.push(plane);
							
				
				//Tracking mouse events to control the active object
			var cursor = new Mouse();
				
			window.addEventListener( 'mousemove', onMouseMove, false );
			window.addEventListener( 'click', onMouseClick, false );
		    
			    //Add spotlights for shadow
			var spotFront = new Light (0, -300, 3000);
			    scene.add(spotFront);
			var spotFrontTop = new Light (0, 1000, -500);
			    scene.add(spotFrontTop);
			var spotBackTop = new Light (1000, 1000,1000);
			    scene.add(spotBackTop);
		
			var spotBackTopF = new Light (3000, 3000, 3000);
			    scene.add(spotBackTopF);
			
		/*	var particles = 50000;
			var geometry = new THREE.BufferGeometry();
			var positions = new Float32Array( particles * 3 );
			var colors = new Float32Array( particles * 3 );
			var color = new THREE.Color();
			var n = 150, n2 = n / 2; // particles spread in the cube
				for ( var i = 0; i < positions.length; i += 3 ) {
				// positions
				var x = Math.random() * n - n2;
				var y = Math.random() * n - n2;
				var z = Math.random() * n - n2;
					positions[ i ]     = x;
					positions[ i + 1 ] = y;
					positions[ i + 2 ] = z;
					// colors
					var vx = ( x / n ) + 0.5;
					var vy = ( y / n ) + 0.5;
					var vz = ( z / n ) + 0.5;
					color.setRGB( vx, vy, vz );
					colors[ i ]     = color.r;
					colors[ i + 1 ] = color.g;
					colors[ i + 2 ] = color.b;
				}

				geometry.addAttribute( 'position', new THREE.BufferAttribute( positions, 3 ) );
				geometry.addAttribute( 'color', new THREE.BufferAttribute( colors, 3 ) );
				geometry.computeBoundingSphere();
			var material = new THREE.PointCloudMaterial( { size: 2, vertexColors: THREE.VertexColors } );
			var	particleSystem = new THREE.PointCloud( geometry, material );
				particleSystem.position.y=50;
				scene.add( particleSystem );
			
		  */  
		    var myScore = new Text("0", 240, 40, 20, 0xff00ff).init();
			var hisScore = new Text("0", 240, 40, 20, 0x0000ff).init();
			    myScore.position.x=-700;
			    hisScore.position.x=700;
			    scene.add(myScore);
			    scene.add(hisScore);
					    
			    render();	
						
		    function render() {
				requestAnimationFrame( render );
				controls.update(0.01);
				camera.lookAt(scene.position);
				renderer.render( scene, camera );
			
				if(started){
					
					
						//started=true;
						scene.add(puck);
						$("#info").hide(); 	
						$("#forTrans").hide(); 	
						$("#stopGame").show(); 
						//	letsGo();
						started=false;
					
				}
					
				//determine the speed of the bat
				batThis.move_x=cursor.speedX();
				batThis.move_z=cursor.speedY();
				
				batThat.position.x=xFromWS;
				batThat.position.z=zFromWS;
								
				toRun(puck);
				
			      
				borders.listenToTheBorder(puck);
				borders.listenToTheRods(puck);				
			
				detectCollisionForCircles(puck,batThis);
				anotherDetectCollisionForCircles(puck,batThis);

				detectCollisionForCircles(puck,batThat);
				
				//Goals
				if(puck.position.z>410||puck.position.z<-420){
					score(puck);
				}
						
				//rotationCloud();
			}
		</script>
</body>
</html>