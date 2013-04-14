window.onerror = function(msg, file, line) {
  csatonce.addLog('[error] ' + msg + ' (at line ' + line + ')');
};
