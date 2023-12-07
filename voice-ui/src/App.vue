<template>
	<body>
		<audio id="audio_on" src="mic_click_on.ogg"></audio>
		<audio id="audio_off" src="mic_click_off.ogg"></audio>
		<div id="logo">
			<img src="nui://pma-voice/fam_logo.png" class="ribbon"/>
		</div>
		<div v-if="voice.uiEnabled" class="voiceInfo">
			<p>
				{{ currentDateTime }}
			</p>
			<p v-if="voice.callInfo !== 0" :class="{ talking: voice.talking }">
				[Call]
			</p>
			<p v-if="voice.radioEnabled && voice.radioChannel !== 0" :class="{ talking: voice.usingRadio }">
				<!-- {{ voice.radioChannel }} Mhz [Radio] -->
				กำลังใช้งานวิทยุ
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
	data() {
		return {
			currentDateTime: this.getCurrentDateTime(), // เริ่มต้นด้วยค่าปัจจุบัน
		};
  	},
	created() {
		// อัปเดตค่าทุกๆ 1 วินาที
		setInterval(() => {
			this.currentDateTime = this.getCurrentDateTime();
		}, 1000);
	},
	methods: {
    	getCurrentDateTime() {
			const now = new Date();
			const year = now.getFullYear();
			const month = (now.getMonth() + 1).toString().padStart(2, '0');
			const day = now.getDate().toString().padStart(2, '0');
			const hours = now.getHours().toString().padStart(2, '0');
			const minutes = now.getMinutes().toString().padStart(2, '0');
			const seconds = now.getSeconds().toString().padStart(2, '0');
			return `${day}/${month}/${year} ${hours}:${minutes}:${seconds}`;
		},
  	},
	setup() {
		const voice = reactive({
			uiEnabled: true,
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
		window.addEventListener("message", function(event) {
			const data = event.data;

			if (data.warningMsg !== undefined ) {
				voice.warningMsg = data.warningMsg;
			}

			if (data.uiEnabled !== undefined) {
				voice.uiEnabled = data.uiEnabled
			}

			if (data.voiceModes !== undefined) {
				voice.voiceModes = JSON.parse(data.voiceModes);
				// Push our own custom type for modes that have their range changed
				let voiceModes = [...voice.voiceModes]
				voiceModes.push([0.0, "Custom"])
				voice.voiceModes = voiceModes
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

			if (data.usingRadio !== undefined && data.usingRadio !== voice.usingRadio) {
				voice.usingRadio = data.usingRadio;
			}
			
			if ((data.talking !== undefined) && !voice.usingRadio) {
				voice.talking = data.talking;
			}

			if (data.sound && voice.radioEnabled && voice.radioChannel !== 0) {
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

			if (data.radioPlayers && data.radioPlayers.length > 0) {
				let radioListElem = document.getElementById("voip-radio-list");

				if (!radioListElem.firstChild) { //add radio list header
					let listHeader = document.createElement("div");

					listHeader.id = "voip-radio-list-header";
					listHeader.textContent = "\uD83D\uDCE1Familie City - Radio List";
					listHeader.style.textDecorationLine = "underline";

					radioListElem.appendChild(listHeader);
				}

				data.radioPlayers.map(p => {
					let listItem = document.createElement("div");
					listItem.id = "voip-radio-list-item-" + p.radioId;
					listItem.textContent = p.radioName + ' ' + (data.self ? "\uD83D\uDD38" : "\uD83D\uDD39");

					radioListElem.appendChild(listItem);
				})
			}

			if (data.radioId != null) {
				let radioListElem = document.getElementById("voip-radio-list");

				// if (!radioListElem.firstChild) { //add radio list header
				// 	let listHeader = document.createElement("div");

				// 	listHeader.id = "voip-radio-list-header";
				// 	listHeader.textContent = "\uD83D\uDCE1Familie City - Radio List";
				// 	listHeader.style.textDecorationLine = "underline";

				// 	radioListElem.appendChild(listHeader);
				// }

				if (data.radioName != null) {
					let listItem = document.createElement("div");

					listItem.id = "voip-radio-list-item-" + data.radioId;
					listItem.textContent = data.radioName + ' ' + (data.self ? "\uD83D\uDD38" : "\uD83D\uDD39");

					radioListElem.appendChild(listItem);
				} else if (data.radioTalking != null) {
					let listItem = document.getElementById("voip-radio-list-item-" + data.radioId)
					
					if (data.radioTalking) {
						listItem.className = "radioTalking"
					} else {
						listItem.className = ""
					}
				} else {
					let listItem = document.getElementById("voip-radio-list-item-" + data.radioId)
					if (listItem) {
						radioListElem.removeChild(listItem);
					}
				}
			}
		});

		fetch(`https://${GetParentResourceName()}/uiReady`, { method: 'POST' });

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
	bottom: 25px;
	/* top: 105px; */
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
	color: rgb(241, 241, 241);
}

.radioTalking {
    color: rgba(1, 176, 240);
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
	color: rgb(255, 255, 255);
	background-color: rgba(39, 39, 39, 0.2);
	font-size: 0.7vw;
	text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
}
.list-item {
	padding-top: 3px;
}
</style>
