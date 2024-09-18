let localStream;

async function getUserMedia() {
  localStream = await navigator.mediaDevices.getUserMedia({
    video: true,
    audio: true,
  });
  document.querySelector("#localVideo").srcObject = localStream;
}

function toggleMute() {
  localStream
    .getAudioTracks()
    .forEach((track) => (track.enabled = !track.enabled));
}

function toggleVideo() {
  localStream
    .getVideoTracks()
    .forEach((track) => (track.enabled = !track.enabled));
}

document.querySelector("#muteButton").addEventListener("click", toggleMute);
document.querySelector("#videoButton").addEventListener("click", toggleVideo);
document.querySelector("#hangUpButton").addEventListener("click", () => {
  localStream.getTracks().forEach((track) => track.stop());
  // Additional logic to leave the room and close connections
});

getUserMedia();
