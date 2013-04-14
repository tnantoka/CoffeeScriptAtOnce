if (!window.console) {
  console = {};
}

console.log = function() {
  var args = Array.prototype.slice.apply(arguments);
  csatonce.addLog('[log] ' + args.join(', '));
};
