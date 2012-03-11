import flash.external.*;
import flash.events.MouseEvent;
import fl.motion.easing.Back;


//Here I'm grabbing the absolute url of cwd
var url = loaderInfo.url;
url = url.substring(0, url.lastIndexOf("/")+1);

//This will contain the movie clip objects to remove later
var links = [];
// net stream object
var nsStream;
// timer for updating player (progress, volume...)
var tmrDisplay;


var videoToPlay = "";
var duration = 60*3;
//This loads the menu into the stage
//Each frame is a different menu
function loadContent(arr, size){
	var h = 0;
	
	//you have to create a TextFormat object to change textsize
	var defaultFormat:TextFormat = new TextFormat();
	defaultFormat.font = "Times New Roman";
	defaultFormat.size = size;
		
	//loop thoruhg menu items
	for(var i in arr){
		//create a custom link item (contains button and link)
		var myMc = new Link();
		links.push(myMc);
		
		myMc.box.defaultTextFormat = defaultFormat;

		myMc.x = 50;
		myMc.y = 130 + h;
		myMc.box.text = arr[i].name;
		myMc.data = arr[i];
		addChild(myMc); 
		h += 350/arr.length;
		
		//Use a function wrapper to keep myMc in scope
		function setUpListeners(myMc){
			myMc.addEventListener(MouseEvent.ROLL_OVER, onRollOverHandler);
			myMc.addEventListener(MouseEvent.ROLL_OUT, onRollOutHandler);
			myMc.addEventListener(MouseEvent.CLICK, onClickHandler);
			myMc.addEventListener(MouseEvent.MOUSE_DOWN, onPressHandler);
			myMc.addEventListener(MouseEvent.MOUSE_UP, onReleaseHandler);
			
			// Makes the hand cursor appear always
			myMc.buttonMode = true;
			myMc.useHandCursor = true;
			myMc.box.mouseEnabled  = false;
			function onRollOverHandler(myEvent:MouseEvent){
				myMc.bullet.visible = true;
				myMc.box.textColor = 0x00F4F400;
			}
			
			function onRollOutHandler(myEvent:MouseEvent){
				myMc.bullet.visible = false;
				myMc.box.textColor = 0x00000000;
			}
			function onClickHandler(myEvent:MouseEvent){
				
			}
			function onPressHandler(myEvent:MouseEvent){
			}
			
			function onReleaseHandler(myEvent:MouseEvent){
				//if we are linking to a different page
				if(myMc.data.keyframe !== undefined){
					//remove all of the list item objects
					clearFrame();
					//only used if switching to videos
					videoToPlay = myMc.data.url;
					duration = myMc.data.len;
					//go to the corect frame
					gotoAndStop(myMc.data.keyframe);
				}else{
					  //if we are doing a request
					  var request:URLRequest = new URLRequest(myMc.data.url);
					  try {
						navigateToURL(request, '_blank');
					  } catch (e:Error) {
						trace("Error occurred!");
					  }
				}
			}
		}
		setUpListeners(myMc);

	}
	 
	
}

var clearFrame = function(){
	for(var i in links){
		removeChild(links[i]);					
	}
	links = [];
	if(tmrDisplay !== undefined){
		tmrDisplay.stop();
	}
	if(nsStream !== undefined){
		nsStream.pause();
	}
}
var back
var sites;
var frame = 0;
var shortPath;
var shortPath2;
//Stop playing through the frames
gotoAndStop(1);
//Called everytime the frame switches
stage.addEventListener(Event.ENTER_FRAME, function(){
	if(frame === currentFrame){
		return;
	}
	frame = currentFrame;
	//Safety check
	if(frame === 1){
		gotoAndStop(2);
		return;
	}
	//You can't access bb unless you are on the right frame.
	//This is bad code, because user makes a new listener every menu change
	if(frame >= 3){
			getChildByName("bb").addEventListener(MouseEvent.CLICK, function(){
				if(currentFrame !== 1){
					clearFrame();
	
				}
			gotoAndStop(2);
		});
	
	}
	
	//Based on the frame pass in information about the menu you want to show
	switch(currentFrame){
		case 2: 
			 sites = [{"name":"Interactive simulations", "keyframe": 3}, 
						{"name":"Interactive lesson guides", "keyframe": 4}, 
						{"name":"Print resources", "keyframe": 5},
						{"name":"Video clips", "keyframe": 6},
						{"name":"Online links", "keyframe": 7}];
			loadContent(sites, 39);
			break;
		case 3:
		shortPath = "website/data/";
		sites = [{"name":"Power and Energy in the Home", "url":url+shortPath+"pe.html"},
				   {"name":"Electricity and Time of Use Pricing", "url":url+shortPath+"tou.html"},
				   {"name":"The Power Grid", "url":url+shortPath+"pg.html"},
				   {"name":"Power Economics and Emissions", "url":url+shortPath+"pee.html"},
				   {"name":"Wind and Storage", "url":url+shortPath+"ws.html"}];
				   loadContent(sites, 39);
			break;
		case 4:
		shortPath = "lessons/interactive/lesson";
		sites = [{"name":"Power and Energy in the Home", "url":url+shortPath+"1/default.html"},
				   {"name":"Electricity and Time of Use Pricing", "url":url+shortPath+"2/default.html"},
				   {"name":"The Power Grid", "url":url+shortPath+"3/default.html"},
				   {"name":"Power Economics and Emissions", "url":url+shortPath+"4/default.html"},
				   {"name":"Wind and Storage", "url":url+shortPath+"5/default.html"}];
				   loadContent(sites, 39);
			break;
		case 5:
		shortPath = "guides/";
		shortPath2 = "lessons/";
		sites = [{"name":"Power and Energy in the Home Guide", "url":url+shortPath+"TCIPquickstart1.pdf"},
				   {"name":"Power and Energy in the Home Lesson", "url":url+shortPath2+"PowerandEnergy.pdf"},
				   {"name":"Electricity and Time of Use Pricing Guide", "url":url+shortPath+"TCIPquickstart1-5.pdf"},
				   {"name":"Electricity and Time of Use Pricing Lesson", "url":url+shortPath2+"TimeSensitive.pdf"},
				   {"name":"The Power Grid Guide", "url":url+shortPath+"TCIPquickstart1.pdf"},
				   {"name":"The Power Grid Lesson", "url":url+shortPath2+"ThePowerGrid.pdf"},
				   {"name":"The Power Grid Game", "url":url+shortPath2+"power grid game.pdf"},
				   {"name":"Power Economics and Emissions Guide", "url":url+shortPath+"TCIPquickstart1.pdf"},
				   {"name":"Power Economics and Emissions Lesson", "url":url+shortPath2+"PowerEconomics&Emissions.pdf"},
				   {"name":"Power Economics and Emissions Student Notebook", "url":url+shortPath2+"PE&EStudentNotebook.pdf"},
				   {"name":"Wind and Storage Guide", "url":url+shortPath+"TCIPquickstart1.pdf"},
				   {"name":"Wind and Storage Lesson", "url":url+shortPath2+"TCIPquickstart1.pdf"}];
				   loadContent(sites, 18);
			break;
		case 6:
		//was coming up undefined for some reason
		//shortPath = "videos/";
		sites = [{"name":"Concentrating Solar Power", "keyframe" : 8, "len": 3*60, "url":url+"videos/concentrating.flv"},
				   {"name":"Geothermal Heat Pumps", "keyframe" : 8, "len": 3*60,"url":url+"videos/geothermal.flv"},
				   {"name":"Lighting Choices", "keyframe" : 8, "len": 3*60,"url":url+"videos/lighting.flv"},
				   {"name":"Wind Turbines", "keyframe" : 8, "len": 3*60,"url":url+"videos/windTurbines.flv"},
				   {"name":"Solar Photovoltaics", "keyframe" : 8, "len": 3*60,"url":url+"videos/solar.flv"}];
				   loadContent(sites, 18);
			break;
		case 7:
		sites = [{"name":"TCIPG Education", "url":"http://tcipg.mste.illinois.edu/"},
				   {"name":"TCIPG", "url":"http://tcipg.org"},
				   {"name":"Energy Explained - The U.S. Energy", "url":"http://www.eia.gov/energyexplained/"},
				   {"name":"Energy Kids - Energy Ant offers energy information, games and activities", "url":"http://www.eia.gov/kids/"},
				   {"name":"Virtual Power Plant Tours – SRP Power", "url":"http://www.srpnet.com/education/tour/default.aspx"},
				   {"name":"Virtual Power Plant Tours – Xcel Energy", "url":"http://energyclassroom.com/powerplanttour/ec_tour1_10_main.html"},
				   {"name":"The Smart Grid: An Introduction - Office of Electricity Deliver & Energy Reliability", "url":"http://energy.gov/oe/downloads/smart-grid-introduction-0"},
				   {"name":"The U.S. Department of Energy ", "url":" http://energy.gov/"}];
				loadContent(sites, 20);
			break;
		case 8:
			include "player.as";
			break;
		default:
			trace("in default", currentFrame);
		break;
		
		
	}
	
	
});
