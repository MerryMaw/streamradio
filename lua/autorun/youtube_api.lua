

if (SERVER) then
	AddCSLuaFile()
else
	function GetHTMLScript(URL)
		//Get ID
		local temp = string.Explode("/",URL)
		temp = string.Explode("v=",temp[#temp])
		temp = string.Explode("?",temp[#temp])
		local ID = temp[1]
		
		return [[
		<!DOCTYPE html>
		<html>
		  <body style="border: 0px;">
			<!-- 1. The <iframe> (and video player) will replace this <div> tag. -->
			
			<iframe id="player" type="text/html"
			src="http://www.youtube.com/embed/]]..ID..[[?enablejsapi=1"
			style="border: 0; position:fixed; top:0; left:0; right:0; bottom:0; width:100%; height:100%"
			frameborder="0"></iframe>
			
			
			<script>
			  function changeVideoID(videoId) {
				var vidFrame = document.getElementByID("player");
				vidFrame.src = "http://www.youtube.com/embed/]]..ID..[[?enablejsapi=1";
			  }
			  
			  // 2. This code loads the IFrame Player API code asynchronously.
			  var tag = document.createElement('script');

			  tag.src = "https://www.youtube.com/iframe_api";
			  var firstScriptTag = document.getElementsByTagName('script')[0];
			  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

			  // 3. This function creates an <iframe> (and YouTube player)
			  //    after the API code downloads.
			  var player;
			  function onYouTubeIframeAPIReady() {
				player = new YT.Player('player', {
				  videoId: ']]..ID..[[',
				  events: {
					'onReady': onPlayerReady,
					'onStateChange': onPlayerStateChange
				  }
				});
			  }

			  // 4. The API will call this function when the video player is ready.
			  function onPlayerReady(event) {
				event.target.playVideo();
			  }

			  function onPlayerStateChange(event) {
			  }
			  
			  function stopVideo() {
				player.stopVideo();
			  }
			</script>
		  </body>
		</html>]]
	end
end