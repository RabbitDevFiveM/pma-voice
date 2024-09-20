<template>
	<body>
		<audio id="audio_on" src="mic_click_on.ogg"></audio>
		<audio id="audio_off" src="mic_click_off.ogg"></audio>
		<!-- <div id="logo">
			<img src="nui://pma-voice/fammain.png" class="ribbon"/>
		</div> -->
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
			uiEnabled: true,
			voiceModes: [],
			voiceMode: 0,
			radioChannel: 0,
			radioEnabled: false,
			usingRadio: false,
			callInfo: 0,
			talking: false,
		});

		// stops from toggling voice at the end of talking
		window.addEventListener("message", function(event) {
			const data = event.data;

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
					listHeader.textContent = "\uD83D\uDCE1Radio List " + "("+(data.radioPlayers.length+1)+ ")";
					listHeader.style.textDecorationLine = "underline";

					radioListElem.appendChild(listHeader);
				}

				data.radioPlayers.map(p => {
					let listItem = document.createElement("div");
					listItem.id = "voip-radio-list-item-" + p.radioId;
					listItem.textContent = (data.self ? "\uD83D\uDD38" : "\uD83D\uDD39") + ' ' + p.radioName;

					radioListElem.appendChild(listItem);
				})
			}

			if (data.radioId != null) {
				let radioListElem = document.getElementById("voip-radio-list");

				if (data.radioName != null) {
					let listItem = document.createElement("div");

					listItem.id = "voip-radio-list-item-" + data.radioId;
					listItem.textContent = (data.self ? "\uD83D\uDD38" : "\uD83D\uDD39") + ' ' + data.radioName;

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

.radioTalking {
	color: rgb(1, 176, 240);
	/* color: rgba(182,56,243); */
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
    top: 120px;
    right: 0%;
    text-align: left;
    padding: 6px;
    margin-right: 20px;
    font-family: sans-serif;
    font-weight: bold;
    color: rgb(255, 255, 255);
    font-size: 0.7vw;
    text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
    max-width: 10em;

    /* Truncate text with ellipsis */
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    
    /* Important: Set display to inline-block */
    display: inline-block;

    /* Prevent content from stretching beyond its container */
    box-sizing: border-box;
}
.list-item {
	padding-top: 3px;
}
</style>
