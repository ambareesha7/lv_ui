// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import Sortable from "../vendor/sortable";

let Hooks = {};
Hooks.Sortable = {
  mounted() {
    let group = this.el.dataset.group;
    let sorter = new Sortable.create(this.el, {
      group: group ? group : undefined,
      animation: 150,
      delay: 100,
      forceFallback: true,
      onEnd: (e) => {
        let params = {
          oldIndex: e.oldIndex,
          newIndex: e.newIndex,
          from: e.from.dataset.list_id,
          to: e.to.dataset.list_id,
          ...e.item.dataset,
        };
        this.pushEventTo(this.el, "reposition", params);
      },
    });
  },
};
Hooks.ChessBoard = {
  mounted() {
    let board = document.querySelectorAll("#game_board");
    board.forEach((e) => {
      console.log("game board", e.children.length);
    });
  },
};
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());
window.addEventListener("phx:clear-input", (e) => {
  let el = document.getElementById("message");
  let container = document.querySelector("#mbox");
  if (el.value) {
    el.value = "";
  }
  container.scrollTop = container.scrollHeight;
  // container.scrollBy(0, 500);
});
// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
