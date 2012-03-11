// ##########################
// ############# CONSTANTS
// ##########################

// time to buffer for the video in sec.
const BUFFER_TIME:Number				= 8;
// start volume when initializing player
const DEFAULT_VOLUME:Number				= 0.6;
// update delay in milliseconds.
const DISPLAY_TIMER_UPDATE_DELAY:int	= 10;
// smoothing for video. may slow down old computers
const SMOOTHING:Boolean					= true;

// ##########################;
// ############# VARIABLES
// ##########################

// flag for knowing if flv has been loaded
var bolLoaded:Boolean					= false;
// flag for volume scrubbing
var bolVolumeScrub:Boolean				= false;
// flag for progress scrubbing
var bolProgressScrub:Boolean			= false;
// holds the last used volume, but never 0
var intLastVolume:Number				= DEFAULT_VOLUME;
// net connection object for net stream
var ncConnection:NetConnection;

// object holds all meta data
var objInfo:Object;
// url to flv file
var strSource:String					= videoToPlay;

// ##########################
// ############# FUNCTIONS
// ##########################

// sets up the player
var initVideoPlayer = function(){
	// hide buttons
	mcVideoControls.btnUnmute.visible	= false;
	mcVideoControls.btnPause.visible	= false;

	// set the progress/preload fill width to 1
	mcVideoControls.mcProgressFill.mcFillRed.width = 1;
	mcVideoControls.mcProgressFill.mcFillGrey.width = 1;

	// add global event listener when mouse is released
	stage.addEventListener( MouseEvent.MOUSE_UP, mouseReleased);

	// add event listeners to all buttons
	mcVideoControls.btnPause.addEventListener(MouseEvent.CLICK, pauseClicked);
	mcVideoControls.btnPlay.addEventListener(MouseEvent.CLICK, playClicked);
	mcVideoControls.btnStop.addEventListener(MouseEvent.CLICK, stopClicked);
	mcVideoControls.btnMute.addEventListener(MouseEvent.CLICK, muteClicked);
	mcVideoControls.btnUnmute.addEventListener(MouseEvent.CLICK, unmuteClicked);
	mcVideoControls.mcVolumeScrubber.btnVolumeScrubber.addEventListener(MouseEvent.MOUSE_DOWN, volumeScrubberClicked);
	mcVideoControls.mcProgressScrubber.btnProgressScrubber.addEventListener(MouseEvent.MOUSE_DOWN, progressScrubberClicked);
	// create timer for updating all visual parts of player and add
	// event listener
	

	tmrDisplay = new Timer(DISPLAY_TIMER_UPDATE_DELAY);
	tmrDisplay.addEventListener(TimerEvent.TIMER, updateDisplay);

	// create a new net connection, add event listener and connect
	// to null because we don't have a media server
	ncConnection = new NetConnection();
	ncConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
	ncConnection.connect(null);

	// create a new netstream with the net connection, add event
	// listener, set client to this for handling meta data and
	// set the buffer time to the value from the constant
	nsStream = new NetStream(ncConnection);
	nsStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
	nsStream.client = this;
	nsStream.bufferTime = BUFFER_TIME;

	// attach net stream to video object on the stage
	vidDisplay.attachNetStream(nsStream);
	// set the smoothing value from the constant
	vidDisplay.smoothing = SMOOTHING;

	// set default volume
	mcVideoControls.mcVolumeScrubber.x = (52 * DEFAULT_VOLUME) + 341;
	mcVideoControls.mcVolumeFill.mcFillRed.width = mcVideoControls.mcVolumeScrubber.x - 394 + 52;
	setVolume(DEFAULT_VOLUME);
}

var playClicked = function(e:MouseEvent):void {
	// check's, if the flv has already begun
	// to download. if so, resume playback, else
	// load the file
	if(!bolLoaded) {
		nsStream.play(strSource);
		bolLoaded = true;
	}
	else{
		nsStream.resume();
	}

	// show video display
	vidDisplay.visible					= true;

	// switch play/pause visibility
	mcVideoControls.btnPause.visible	= true;
	mcVideoControls.btnPlay.visible		= false;
}

var pauseClicked = function(e:MouseEvent):void {
	// pause video
	nsStream.pause();

	// switch play/pause visibility
	mcVideoControls.btnPause.visible	= false;
	mcVideoControls.btnPlay.visible		= true;
}

var stopClicked = function(e:MouseEvent):void {
	// calls stop function
	stopVideoPlayer();
}

var muteClicked = function(e:MouseEvent):void {
	// set volume to 0
	setVolume(0);

	// update scrubber and fill position/width
	mcVideoControls.mcVolumeScrubber.x				= 341;
	mcVideoControls.mcVolumeFill.mcFillRed.width	= 1;
}

var unmuteClicked = function(e:MouseEvent):void {
	// set volume to last used value
	setVolume(intLastVolume);

	// update scrubber and fill position/width
	mcVideoControls.mcVolumeScrubber.x = (53 * intLastVolume) + 341;
	mcVideoControls.mcVolumeFill.mcFillRed.width = mcVideoControls.mcVolumeScrubber.x - 394 + 53;
}

var volumeScrubberClicked = function(e:MouseEvent):void {
	// set volume scrub flag to true
	bolVolumeScrub = true;

	// start drag
	mcVideoControls.mcVolumeScrubber.startDrag(false, new Rectangle(341, 19, 53, 0));
}

var progressScrubberClicked = function(e:MouseEvent):void {
	// set progress scrub flag to true
	bolProgressScrub = true;

	// start drag
	mcVideoControls.mcProgressScrubber.startDrag(false, new Rectangle(0, 2, 432, 0));
}

var mouseReleased = function(e:MouseEvent) {
	// set progress/volume scrub to false
	bolVolumeScrub		= false;
	bolProgressScrub	= false;

	// stop all dragging actions
	mcVideoControls.mcProgressScrubber.stopDrag();
	mcVideoControls.mcVolumeScrubber.stopDrag();

	// update progress/volume fill
	mcVideoControls.mcProgressFill.mcFillRed.width	= mcVideoControls.mcProgressScrubber.x + 5;
	mcVideoControls.mcVolumeFill.mcFillRed.width	= mcVideoControls.mcVolumeScrubber.x - 394 + 53;

	// save the volume if it's greater than zero
	if((mcVideoControls.mcVolumeScrubber.x - 341) / 53 > 0)
		intLastVolume = (mcVideoControls.mcVolumeScrubber.x - 341) / 53;
}

var updateDisplay = function(e:TimerEvent):void {
	// checks, if user is scrubbing. if so, seek in the video
	// if not, just update the position of the scrubber according
	// to the current time
	trace("Quinn");
	trace(bolProgressScrub);
	if(bolProgressScrub)
		nsStream.seek(Math.round(mcVideoControls.mcProgressScrubber.x * objInfo.duration / 432))
	else
		mcVideoControls.mcProgressScrubber.x = nsStream.time * 432 / objInfo.duration; 

	// set time and duration label
	mcVideoControls.lblTimeDuration.htmlText		= "" + formatTime(nsStream.time) + " / " + formatTime(objInfo.duration);

	// update the width from the progress bar. the grey one displays
	// the loading progress
	mcVideoControls.mcProgressFill.mcFillRed.width	= mcVideoControls.mcProgressScrubber.x + 5;
	mcVideoControls.mcProgressFill.mcFillGrey.width	= nsStream.bytesLoaded * 438 / nsStream.bytesTotal;

	// update volume and the red fill width when user is scrubbing
	if(bolVolumeScrub) {
		setVolume((mcVideoControls.mcVolumeScrubber.x - 341) / 53);
		mcVideoControls.mcVolumeFill.mcFillRed.width = mcVideoControls.mcVolumeScrubber.x - 394 + 53;
	}
}

var onMetaData = function(info:Object):void {
	// stores meta data in a object
	objInfo = info;

	// now we can start the timer because
	// we have all the neccesary data
	tmrDisplay.start();
}

var netStatusHandler = function(event:NetStatusEvent):void {
	// handles net status events
	switch (event.info.code) {
		// trace a messeage when the stream is not found
		case "NetStream.Play.StreamNotFound":
			trace("Stream not found: " + strSource);
		break;

		// when the video reaches its end, we stop the player
		case "NetStream.Play.Stop":
			stopVideoPlayer();
		break;
	}
}

var stopVideoPlayer = function():void {
	// pause netstream, set time position to zero
	nsStream.pause();
	nsStream.seek(0);

	// in order to clear the display, we need to
	// set the visibility to false since the clear
	// function has a bug
	vidDisplay.visible			= false;

	// switch play/pause button visibility
	mcVideoControls.btnPause.visible	= false;
	mcVideoControls.btnPlay.visible		= true;
}

var setVolume = function(intVolume:Number = 0):void {
	// create soundtransform object with the volume from
	// the parameter
	var sndTransform	= new SoundTransform(intVolume);
	// assign object to netstream sound transform object
	nsStream.soundTransform	= sndTransform;
	// hides/shows mute and unmute button according to the
	// volume
	if(intVolume > 0) {
		mcVideoControls.btnMute.visible		= true;
		mcVideoControls.btnUnmute.visible	= false;
	} else {
		mcVideoControls.btnMute.visible		= false;
		mcVideoControls.btnUnmute.visible	= true;
	}
}

var formatTime = function(t:int):String {
	// returns the minutes and seconds with leading zeros
	// for example: 70 returns 01:10
	var s:int = Math.round(t);
	var m:int = 0;
	if (s > 0) {
		while (s > 59) {
			m++;
			s -= 60;
		}
		return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
	} else {
		return "00:00";
	}
}

// ##########################
// ############# INIT PLAYER
// ##########################

initVideoPlayer();
playClicked(null);
objInfo = {"duration": duration};

	// now we can start the timer because
	// we have all the neccesary data
tmrDisplay.start();
	