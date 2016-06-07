package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class markTip extends Sprite
	{
		public var vp:ViewPage;
		public function markTip()
		{
			super();
			this.addEventListener(MouseEvent.ROLL_OUT,rollOver);
			this.addEventListener(MouseEvent.ROLL_OUT,rollOut);
		}
		
		public function rollOver(evt:MouseEvent):void{
			this.graphics.clear();
			this.graphics.beginFill(0xff0000);
			this.graphics.drawRect(0,0,40,30);
			this.graphics.endFill();
		}
		
		public function rollOut(evt:MouseEvent):void{
			this.graphics.clear();
			this.graphics.beginFill(0xff0000,0.3);
			this.graphics.drawRect(0,0,20,30);
			this.graphics.endFill();
		}
		
		public function setMark():void{
			
		}
	}
}