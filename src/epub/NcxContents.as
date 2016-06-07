package epub
{
	import epub.NcxNavPoint;
	import epub.OpfPage;
	
	public class NcxContents
	{
		
		protected var _navPoints:Array; // of NcxNavPoint
		protected var _navTree:Object;
		
		// The contents define additional navigation meta-data on top of the ncx spine
		public function NcxContents()
		{
			_navPoints = new Array();
			_navTree = new Object();
		}
		
		public function addNavPoint(pPoint:NcxNavPoint):void {
			_navPoints.push(pPoint);
		}
		
		/*
		 * Returns a copy array of all navigation points in the TOC
		 */
		public function get contents():Array {
			return _navPoints.slice();
		}

	}
}