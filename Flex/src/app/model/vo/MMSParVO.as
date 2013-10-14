package app.model.vo
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.JPEGEncoder;

	[Bindable]
	public class MMSParVO
	{
		public var imgName:String = "";
		public var imgFile:FileReference = new FileReference;
		public var bitmapData:BitmapData;   
		public var text:String = "";
		public var dur:Number = 5;
		
		public var data:ByteArray;
		
		public function MMSParVO()
		{
			imgFile.addEventListener(Event.SELECT,fileReferenceSelectHandler);   
		}
		
		private function fileReferenceSelectHandler(e:Event):void   
		{   
			var loader:Loader = new Loader();
			
			imgFile.addEventListener(Event.COMPLETE,fileReferenceCompleteHandler); 
			
			imgFile.load();   
			
			imgName = imgFile.name;
			
			function fileReferenceCompleteHandler(e:Event):void   
			{   
				imgFile.removeEventListener(Event.COMPLETE,fileReferenceCompleteHandler);
								
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCompleteHandler);   
				loader.loadBytes(imgFile.data);   				
			}   
			
			function loaderCompleteHandler(e:Event):void   
			{   
				var bitmap:Bitmap = Bitmap(loader.content);   
								
				var scale:Number = (bitmap.width / bitmap.height) / (240 / 320);
				var scale_width:Number = (scale > 1)?240:(scale * 240);
				var scale_height:Number = (scale > 1)?(320 / scale):320;
				
				bitmapData = new BitmapData (scale_width, scale_height);
				
				var scale_W:Number = scale_width / bitmap.width;
				var matrix:Matrix = new Matrix(scale_W,0,0,scale_W,0,0);
				bitmapData.draw(bitmap.bitmapData,matrix);
				
				var jpgEncoder:JPEGEncoder = new JPEGEncoder(85);
				
				data = jpgEncoder.encode(bitmapData);
			}   
		}   
				
		public function downImg(url:String):void
		{
			var downloadURL:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE,fileReferenceCompleteHandler);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(downloadURL);
			
			function fileReferenceCompleteHandler(e:Event):void   
			{   
				urlLoader.removeEventListener(Event.COMPLETE,fileReferenceCompleteHandler);
				
				//data = urlLoader.data;
				
				var loader:Loader = new Loader();				
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCompleteHandler);   
				loader.loadBytes(urlLoader.data);   				
			}   
			
			function loaderCompleteHandler(e:Event):void   
			{   
				var bitmap:Bitmap = Bitmap((e.currentTarget as LoaderInfo).content);  
				//bitmapData = bitmap.bitmapData;  				
				
				var scale:Number = (bitmap.width / bitmap.height) / (240 / 320);
				var scale_width:Number = (scale > 1)?240:(scale * 240);
				var scale_height:Number = (scale > 1)?(320 / scale):320;
				
				bitmapData = new BitmapData (scale_width, scale_height);
				
				var scale_W:Number = scale_width / bitmap.width;
				var matrix:Matrix = new Matrix(scale_W,0,0,scale_W,0,0);
				bitmapData.draw(bitmap.bitmapData,matrix);
				
				var jpgEncoder:JPEGEncoder = new JPEGEncoder(85);
				
				data = jpgEncoder.encode(bitmapData);
			}   
		}
		
		public function downText(url:String):void
		{			
			var downloadURL:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE,completeHandler);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(downloadURL);
			
			function completeHandler(event:Event):void
			{
				urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
				var byteArray:ByteArray = urlLoader.data;
				text = byteArray.readMultiByte(byteArray.bytesAvailable, "gb18030");
			}
		}
	}
}