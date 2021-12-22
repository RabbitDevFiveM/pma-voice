<template>
	<body>
		<audio id="audio_on" src="mic_click_on.ogg"></audio>
		<audio id="audio_off" src="mic_click_off.ogg"></audio>
		<div id="logo">
			<img src="https://cdn.discordapp.com/attachments/923167050044678156/923167813001179157/fam-pma.png" class="ribbon"/>
		</div>
		<div class="voiceInfo">
			<p v-if="voice.callInfo !== 0" :class="{ talking: voice.talking }">
				[Call]
			</p>
			<p v-if="voice.radioEnabled && voice.radioChannel !== 0" :class="{ talking: voice.usingRadio }">
				{{ voice.radioChannel }} Mhz [Radio]
			</p>
			<p v-if="voice.warningMsg" :class="{ warning: voice.warningMsg }">
				[Familie City] {{ voice.warningMsg }}
			</p>
			<p v-else-if="!voice.warningMsg && voice.voiceModes.length" :class="{ talking: voice.talking }">
				{{ voice.voiceMode === "Muted" ? "Muted" : voice.voiceModes[voice.voiceMode] && voice.voiceModes[voice.voiceMode][1] }}
			<!-- <p v-if="voice.voiceModes.length" :class="{ talking: voice.talking }">
				{{ voice.voiceModes[voice.voiceMode][1] }} [Range] -->
			</p>
		</div>
		<div class="radio-list-container" id="voip-radio-list">
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

			if (data.clearRadio === true) {
				let radioListElem = document.getElementById("voip-radio-list");
				while (radioListElem.firstChild) {
					radioListElem.removeChild(radioListElem.firstChild)
				}
			}

			if (data.radioId != null) {
				let radioListElem = document.getElementById("voip-radio-list");

				if (!radioListElem.firstChild) { //add radio list header
					let listHeader = document.createElement("div");

					listHeader.id = "voip-radio-list-header";
					listHeader.textContent = "\uD83D\uDCE1Familie City - Radio List";
					listHeader.style.textDecorationLine = "underline";

					radioListElem.appendChild(listHeader);
				}

				if (data.radioName != null) {
					let listItem = document.createElement("div");

					listItem.id = "voip-radio-list-item-" + data.radioId;
					listItem.textContent = data.radioName + ' ' + (data.self ? "\uD83D\uDD38" : "\uD83D\uDD39");

					radioListElem.appendChild(listItem);
				} else if (data.radioTalking != null) {
					let listItem = document.getElementById("voip-radio-list-item-" + data.radioId)
					
					if (data.radioTalking) {
						listItem.className = "talking"
					} else {
						listItem.className = ""
					}
				} else {
					let listItem = document.getElementById("voip-radio-list-item-" + data.radioId)
					radioListElem.removeChild(listItem);
				}
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
	top: 30px;
	right: 0px;
	width: 4.5em;
}
.voiceInfo {
	font-family: Avenir, Helvetica, Arial, sans-serif;
	position: fixed;
	text-align: right;
	/* bottom: 25px; */
	top: 105px;
	padding: 5px;
	right: 8px;
	font-size: 0.7vw;
	font-weight: bold;
	color: rgb(1, 176, 240);
	/* https://stackoverflow.com/questions/4772906/css-is-it-possible-to-add-a-black-outline-around-each-character-in-text */
	background-color: rgba(39, 39, 39, 0.8);
	border-radius: 0.9em;
	text-shadow: -1px 0 black, 0 1px rgb(46, 46, 46), 1px 0 black, 0 -1px black;
}
.talking {
	color: rgba(244, 196, 65, 255);
}
.warning {
	color: #ff7979;
	text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
}
p {
	margin: 0;
}
.radio-list-container {
	position: absolute;
	top: 140px;
	right: 0%;
	text-align: right;
	padding: 6px;
	font-family: sans-serif;
	font-weight: bold;
	color: rgb(1, 176, 240);
	font-size: 0.7vw;
	text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
}
.list-item {
	padding-top: 3px;
}
</style>
