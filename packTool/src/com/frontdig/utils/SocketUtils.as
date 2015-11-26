package com.frontdig.utils
{
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;

	public class SocketUtils
	{
		public function SocketUtils()
		{
		}
		private static var _socket:ServerSocket;
		public static function onConnect():void{
			if(_socket == null){
				_socket = new ServerSocket();
				_socket
				_socket.bind(9999,"192.168.1.197");
				_socket.addEventListener(ServerSocketConnectEvent.CONNECT,onSocketConnect);
				_socket.listen();
			}else{
				_socket.close();
			}
		}
		private static var _curSocket:Socket;
		private static var step:int = 0;
		protected static function onSocketConnect(event:ServerSocketConnectEvent):void
		{
			// TODO Auto-generated method stub
			_curSocket = event.socket;
			step = 0;
//			trace(socket);
			
//				send();
			
		}
		public static function send():void{
			step = step + 1;
			if((step)==1){
				_curSocket.writeInt(20);
				_curSocket.writeInt(1);
				_curSocket.writeInt(2);
			}else if((step)==2){
				_curSocket.writeInt(3);
				_curSocket.writeInt(4);
				_curSocket.writeInt(5);
				_curSocket.writeInt(20);
				_curSocket.writeInt(1);
				_curSocket.writeInt(2);
				_curSocket.writeInt(3);
				_curSocket.writeInt(4);
				_curSocket.writeInt(5);
				_curSocket.writeInt(20);
			}else if((step)==3){
				_curSocket.writeInt(1);
				_curSocket.writeInt(2);
				_curSocket.writeInt(3);
				_curSocket.writeInt(4);
				_curSocket.writeInt(5);
				step = 0;
			}
//				_curSocket.writeInt(20);
//				_curSocket.writeInt(1);
//				_curSocket.writeInt(2);
//				_curSocket.writeInt(3);
//				_curSocket.writeInt(4);
//				_curSocket.writeInt(5);
//				_curSocket.writeInt(20);
//				_curSocket.writeInt(1);
//				_curSocket.writeInt(2);
//				_curSocket.writeInt(3);
//				_curSocket.writeInt(4);
//				_curSocket.writeInt(5);
//				_curSocket.writeInt(20);
//				_curSocket.writeInt(1);
//				_curSocket.writeInt(2);
//				_curSocket.writeInt(3);
//				_curSocket.writeInt(4);
//				_curSocket.writeInt(5);
			_curSocket.flush();
//			_curSocket.flush();
		}
		
	}
}