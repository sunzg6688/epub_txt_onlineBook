package txt
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;
	
	public class TxtModel extends EventDispatcher
	{
		
		protected var _bookReady:Boolean;
		protected var _statusMessage:String;
		protected var _percentLoaded:Number;
		
		public function TxtModel(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function loadBook(bookUrl:String):void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoaded);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load( new URLRequest(bookUrl) );
			trace("Loading book...");
			_percentLoaded = 2;
		}
		
		private function onProgress(e:ProgressEvent):void {
			_percentLoaded = Math.floor( 100 * e.bytesLoaded / e.bytesTotal);
			_statusMessage = "Loading txt file..." + _percentLoaded + "%";
			FlexGlobals.topLevelApplication.loadingBook(_statusMessage,_percentLoaded);
		}
		
		public var txtArr:Array=[];
		
		private function onLoaded(e:Event):void {
			trace("txt file loaded");
			var loadedData:String=e.target.data;
			trace("txt.length::::::::",loadedData.length);
			var lg:int=loadedData.length;
			var i:int=0;
			while(i<lg){
				var s:String=loadedData.substr(i,40000);
				i=i+40000;
				txtArr.push(s);
			}
			FlexGlobals.topLevelApplication.initTxt(txtArr);
		}
		
		private function onLoadError(e:IOErrorEvent):void {
			trace("Book load error");
		}
	}
}