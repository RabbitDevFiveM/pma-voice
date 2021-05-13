<template>
	<body>
		<audio id="audio_on" src="mic_click_on.ogg"></audio>
		<audio id="audio_off" src="mic_click_off.ogg"></audio>
		<div id="logo">
			<img src="./logo.png" class="ribbon"/>
		</div>
		<div class="voiceInfo">
			<p v-if="voice.callInfo !== 0" :class="{ talking: voice.talking }">
				[Call]
			</p>
			<p v-if="voice.radioEnabled && voice.radioChannel !== 0" :class="{ talking: voice.usingRadio }">
				{{ voice.radioChannel }} Mhz [Radio]
			</p>

			<p v-if="voice.warningMsg" :class="{ warning: voice.warningMsg }">
				[Warning] {{ voice.warningMsg }}
			</p>

			<p v-else-if="!voice.warningMsg && voice.voiceModes.length" :class="{ talking: voice.talking }">
				[Mumble] {{ voice.voiceMode === "Muted" ? "Muted" : voice.voiceModes[voice.voiceMode] && voice.voiceModes[voice.voiceMode][1] }}
			</p>
			
		</div>
	</body>
</template>

<script>
import { reactive } from "vue";
export default {
	name: "App",
	setup() {
		const voice = reactive({
			voiceModes: [],
			voiceMode: 0,
			radioChannel: 0,
			radioEnabled: false,
			usingRadio: false,
			callInfo: 0,
			talking: false,
			warningMsg: null,
		});

		// stops from toggling voice at the end of talking
		let usingUpdated = false
		window.addEventListener("message", function(event) {
			const data = event.data;

			if (data.warningMsg !== undefined ) {
				voice.warningMsg = data.warningMsg;
			}

			if (data.voiceModes !== undefined) {
				voice.voiceModes = JSON.parse(data.voiceModes);
			}

			if (data.voiceMode !== undefined) {
				voice.voiceMode = data.voiceMode;
			}

			if (data.radioChannel !== undefined) {
				voice.radioChannel = data.radioChannel;
			}

			if (data.radioEnabled !== undefined) {
				voice.radioEnabled = data.radioEnabled;
			}

			if (data.callInfo !== undefined) {
				voice.callInfo = data.callInfo;
			}

			if (data.usingRadio !== voice.usingRadio) {
				usingUpdated = true
				voice.usingRadio = data.usingRadio
				usingUpdated = false
			}
			
			if ((data.talking !== undefined) && !voice.usingRadio && !usingUpdated){
				voice.talking = data.talking
			}

			if (data.sound && voice.radioEnabled) {
				let click = document.getElementById(data.sound);
				// discard these errors as its usually just a 'uncaught promise' from two clicks happening too fast.
				click.load();
				click.volume = data.volume;
				click.play().catch((e) => {});
			}
		});

		return { voice };
	},
};
</script>

<style>
#logo {
	position: reactive;
}
#logo img {
	position: absolute;
	top: 2px;
	right: 6em;
	width: 4.5em;
}
.voiceInfo {
	font-family: Avenir, Helvetica, Arial, sans-serif;
	position: fixed;
	text-align: right;
	bottom: 5px;
	padding: 5px;
	right: 30px;
	font-size: 0.6vw;
	font-weight: bold;
	color: rgb(1, 176, 240);
	/* https://stackoverflow.com/questions/4772906/css-is-it-possible-to-add-a-black-outline-around-each-character-in-text */
	background-color: rgba(39, 39, 39, 0.8);
	border-radius: 0.9em;
	text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
}
.talking {
	color: rgba(244, 196, 65, 255);
}
.warning {
	color: #ff0000;
	text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
}
p {
	margin: 0;
}
</style>
